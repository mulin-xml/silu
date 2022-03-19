// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'utils.dart';
import 'oss.dart';

class OssImage extends ImageProvider<OssImage> {
  /// Creates an object that decodes a [File] as an image.
  ///
  /// The arguments must not be null.
  OssImage(this.filename, {this.scale = 1.0});

  /// The file to decode into an image.
  final String filename;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  bool isFileExist = false;

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

  // 并不会在构造时调用，而是在呈现时调用
  Future<ui.Codec> _loadAsync(OssImage key, DecoderCallback decode) async {
    assert(key == this);

    if (!isFileExist) {
      isFileExist = await loadImg(filename);
    }
    var cachePath = Utils().cachePath;
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

Future<bool> loadImg(String ossImgKey) async {
  var cachePath = Utils().cachePath;
  if (File('$cachePath/$ossImgKey').existsSync()) {
    return true;
  } else {
    var rsp = await Bucket().getObject('images/$ossImgKey', '$cachePath/$ossImgKey');
    return rsp.statusCode == HttpStatus.ok;
  }
}
