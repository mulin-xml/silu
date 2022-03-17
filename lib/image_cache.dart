import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'oss.dart';

class OssImage extends ImageProvider<OssImage> {
  /// Creates an object that decodes a [File] as an image.
  ///
  /// The arguments must not be null.
  const OssImage(this.filename, {this.scale = 1.0});

  /// The file to decode into an image.
  final String filename;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<OssImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<OssImage>(this);
  }

  @override
  ImageStreamCompleter load(OssImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.filename,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: $filename'),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(OssImage key, DecoderCallback decode) async {
    assert(key == this);

    var cachePath = (await getTemporaryDirectory()).path;
    if (!File('$cachePath/$filename').existsSync()) {
      var rsp = await Bucket().getObject('images/$filename', '$cachePath/$filename');
      if (rsp.statusCode != HttpStatus.ok) {
        // The file may become available later.
        PaintingBinding.instance!.imageCache!.evict(key);
        throw StateError('File is empty and cannot be loaded as an image.');
      }
    }

    final Uint8List bytes = await File('$cachePath/$filename').readAsBytes();
    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance!.imageCache!.evict(key);
      throw StateError('File is empty and cannot be loaded as an image.');
    }

    return decode(bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is OssImage && other.filename == filename && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(filename, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'OssImage')}("$filename", scale: $scale)';
}
