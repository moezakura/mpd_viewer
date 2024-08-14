import 'dart:typed_data';

import 'package:dart_mpd/dart_mpd.dart';
import 'package:mutex/mutex.dart';

class AlbumArtDownloadService {
  final MpdClient client;
  final Mutex downloadingMutex = Mutex();
  Map<String, bool> downloading = {};

  AlbumArtDownloadService(this.client);

  Future<Uint8List> download(String file) async {
    await downloadingMutex.acquire();
    final isDownloading = downloading.containsKey(file);
    downloadingMutex.release();
    if (isDownloading) {
      return Future.error('Already downloading');
    }
    await downloadingMutex.acquire();
    downloading[file] = true;
    downloadingMutex.release();

    int offset = 0;
    int offsetSize = 0;
    Uint8List imageData = Uint8List(0);

    final imageDataBySize = await client.readpicture(file, 0);
    offsetSize = imageDataBySize!.size!;

    while (offset < offsetSize) {
      final imageResponse = await client.readpicture(file, offset);
      offset += imageResponse!.binary!;
      imageData = Uint8List.fromList(imageData + imageResponse.bytes);
    }

    await downloadingMutex.acquire();
    downloading.remove(file);
    downloadingMutex.release();

    return imageData;
  }
}
