import 'dart:async';

import 'package:dart_mpd/dart_mpd.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mpd_viewer/services/AlbumArtDownloadService.dart';
import 'package:mpd_viewer/services/ImageCacheService.dart';
import 'package:mpd_viewer/services/SettingsService.dart';
import 'package:mpd_viewer/widgets/ConnectionErrorOverlay.dart';
import 'package:mpd_viewer/widgets/GlowingCircularImage.dart';
import 'package:mpd_viewer/widgets/MusicPlayerControls.dart';
import 'package:mpd_viewer/widgets/CenteredTwoLineSongInfoWidget.dart';
import 'package:flutter/services.dart';
import 'package:mpd_viewer/widgets/SettingsIconButton.dart';
import 'package:mpd_viewer/widgets/SimpleSongCardWidget.dart';

class Song {
  final int pos;
  final String file;
  final String title;
  final String artist;
  final String album;
  final String? imageUrl;

  Song({
    required this.pos,
    required this.file,
    required this.title,
    required this.artist,
    required this.album,
    this.imageUrl,
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MPD Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurple,
          background: Colors.black,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'MPD Viewer'),
      darkTheme: ThemeData.dark(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MpdClient? client;
  final ImageCacheService imageCacheService = ImageCacheService();
  final SettingsService settingsService = SettingsService();
  AlbumArtDownloadService? albumArtDownloadService;

  Song currentSong = Song(pos: 0, file: '', title: '', artist: '', album: '');
  double currentProgress = 0;
  bool isPlaying = false;
  Song? nextSong;
  Song? previousSong;

  bool isConnecting = false;
  int connectWaitCount = 0;
  int previousConnectWaitCount = 0;

  String connectHost = '';
  int connectPort = 0;

  void connectMpd() async {
    if (connectHost.isEmpty || connectPort == 0) {
      connectHost = await settingsService.getConnectHost();
      connectPort = await settingsService.getConnectPort();
    }
    client = MpdClient(
      connectionDetails: MpdConnectionDetails(
        host: connectHost,
        port: connectPort,
        timeout: const Duration(seconds: 1),
      ),
      onError: (error, stackTrace) {
        debugPrint("Error: $error");
        // connectWaitCount * 3秒待って再接続
        Future.delayed(Duration(seconds: connectWaitCount * 3), () {
          connectMpd();
        });
        setState(() {
          isConnecting = true;
          connectWaitCount++;
        });
      },
      onConnect: () {
        debugPrint("Connected to MPD");
        setState(() {
          isConnecting = false;
          connectWaitCount = 0;
        });
      },
    );
    await client!.ping();
  }

  @override
  void initState() {
    super.initState();

    // 非同期関数をここで実行させる
    () async {
      connectMpd();
      albumArtDownloadService = AlbumArtDownloadService(client!);
    }();

    // 300msごとに実行
    Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      try {
        if (!client!.connection.isConnected) {
          throw Exception("Not connected");
        }
        await client!.ping();

        await getCurrentSong();
        // プレイリストを取得
        final playlist = await client!.playlistinfo();
        final nextSongPos = currentSong.pos + 1;
        final previousSongPos = currentSong.pos - 1;
        // nextがあれば取得
        if (playlist.length > nextSongPos) {
          final nextSongPlaylistItem = playlist[nextSongPos];
          final nextSongItem = await getSongWithDownload(nextSongPlaylistItem);
          setState(() {
            nextSong = nextSongItem;
          });
        } else {
          setState(() {
            nextSong = null;
          });
        }
        // previousがあれば取得
        if (previousSongPos >= 0) {
          final previousSongPlaylistItem = playlist[previousSongPos];
          final previousSongItem =
              await getSongWithDownload(previousSongPlaylistItem);
          setState(() {
            previousSong = previousSongItem;
          });
        } else {
          setState(() {
            previousSong = null;
          });
        }
      } catch (e) {
        debugPrint("Error: $e");
        if (previousConnectWaitCount == connectWaitCount) {
          Future.delayed(Duration(seconds: connectWaitCount * 3), () {
            connectMpd();
            setState(() {
              previousConnectWaitCount = connectWaitCount;
            });
          });
          setState(() {
            isConnecting = true;
            connectWaitCount++;
          });
        }
      }
    });
  }

  Future<void> getCurrentSong() async {
    final song = await client!.currentsong();
    final songId = "${song!.id}.jpg";
    final isCacheImage = await imageCacheService.isCached(songId);
    if (!isCacheImage) {
      try {
        final imageData = await albumArtDownloadService!.download(song.file);
        await imageCacheService.cacheImage(songId, imageData);
      } catch (e) {}
    }

    // 現在の曲情報を取得
    setState(() {
      if (currentSong.file != song.file) {
        currentSong = Song(
          pos: song.pos ?? 0,
          file: song.file ?? "",
          title: song.title?.first ?? "",
          artist: song.artist?.first ?? "",
          album: song.album?.first ?? "",
          imageUrl: null,
        );
      }
    });

    try {
      final imageData = await imageCacheService.getCachedImage(songId);
      setState(() {
        if (currentSong.imageUrl != imageData.path) {
          currentSong = Song(
            pos: song.pos ?? 0,
            file: song.file ?? "",
            title: song.title?.first ?? "",
            artist: song.artist?.first ?? "",
            album: song.album?.first ?? "",
            imageUrl: imageData.path,
          );
        }
      });
    } catch (e) {}

    // 現在の状態を取得する
    final status = await client!.status();
    setState(() {
      isPlaying = status.state == MpdState.play;
      currentProgress = (status.elapsed ?? 1) / (status.duration ?? 1);
    });
  }

  Future<Song> getSongWithDownload(MpdSong song) async {
    final songId = "${song.id}.jpg";
    final isCacheImage = await imageCacheService.isCached(songId);
    if (!isCacheImage) {
      try {
        final imageData = await albumArtDownloadService!.download(song.file);
        await imageCacheService.cacheImage(songId, imageData);
      } catch (e) {}
    }

    try {
      final imageData = await imageCacheService.getCachedImage(songId);
      return Song(
        pos: song.pos ?? 0,
        file: song.file ?? "",
        title: song.title?.first ?? "",
        artist: song.artist?.first ?? "",
        album: song.album?.first ?? "",
        imageUrl: imageData.path,
      );
    } catch (e) {
      return Song(
        pos: song.pos ?? 0,
        file: song.file ?? "",
        title: song.title?.first ?? "",
        artist: song.artist?.first ?? "",
        album: song.album?.first ?? "",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              children: [
                GlowingCircularImage(
                  imagePath: currentSong.imageUrl,
                  size: 250.0,
                  glowIntensity: 80.0,
                ),
                Positioned(
                  bottom: 0,
                  child: CenteredTwoLineSongInfoWidget(
                      title: currentSong.title,
                      album: currentSong.album,
                      artist: currentSong.artist),
                )
              ],
            ),

            Spacer(),
            // 横並びに表示
            Container(
              height: 80,
              padding: const EdgeInsets.fromLTRB(
                32,
                0,
                32,
                0,
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                (previousSong != null)
                    ? Row(
                        children: [
                          // 戻るアイコン
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_outlined),
                            iconSize: 48,
                            onPressed: () {
                              // 前の曲への移動処理
                              client!.previous();
                            },
                          ),
                          SimpleSongCardWidget(
                              imagePath: previousSong!.imageUrl,
                              title: previousSong!.title,
                              album: previousSong!.album,
                              artist: previousSong!.artist)
                        ],
                      )
                    : Container(),
                const Spacer(),
                (nextSong != null)
                    ? Row(children: [
                        SimpleSongCardWidget(
                            imagePath: nextSong!.imageUrl,
                            title: nextSong!.title,
                            album: nextSong!.album,
                            artist: nextSong!.artist),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
                          iconSize: 48,
                          onPressed: () {
                            // 前の曲への移動処理
                            client!.next();
                          },
                        ),
                      ])
                    : Container(),
              ]),
            ),

            Spacer(),

            MusicPlayerControls(
              onPlayPause: () {
                // 再生/一時停止の処理
                if (isPlaying) {
                  client!.pause();
                } else {
                  client!.connection.send("play");
                }
              },
              onPrevious: () {
                // 前の曲への移動処理
                client!.previous();
              },
              onNext: () {
                // 次の曲への移動処理
                client!.next();
              },
              value: currentProgress,
              // 現在の再生位置（0.0 から 1.0 の範囲）
              onChanged: (newValue) {
                // スライダーの値が変更されたときの処理
              },
              isPlaying: isPlaying, // 現在再生中かどうか
            )
          ],
        ),
        ConnectionErrorOverlay(
          isVisible: isConnecting,
          connectHost: connectHost,
          connectPort: connectPort,
        ),

        // 設定アイコンボタン
        SettingsIconButton(
          onSettingsSaved: (hostname, port) {
            print('Hostname: $hostname, Port: $port');
            // ここで設定を保存したり、アプリケーションの状態を更新したりします
            connectHost = hostname;
            connectPort = int.parse(port);
            // 接続先の保存
            settingsService.setConnectHost(hostname);
            settingsService.setConnectPort(int.parse(port));
          },
          top: 24.0,
          right: 24.0,
          defaultHostname: connectHost,
          defaultPort: connectPort.toString(),
        ),
      ],
    ));
  }
}
