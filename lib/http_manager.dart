// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as tpimg;

import 'package:silu/oss.dart';
import 'package:silu/utils.dart';

class SiluResponse {
  SiluResponse(this.statusCode, this.data);
  int statusCode;
  dynamic data;
}

class SiluRequest {
  static getInstance() => _instance;
  static final _instance = SiluRequest._internal();
  factory SiluRequest() => getInstance();
  SiluRequest._internal();
  static final _dio = Dio(BaseOptions(baseUrl: 'http://0--0.top/apis/'));

  Future<SiluResponse> post(String api, dynamic map) async {
    try {
      var response = await _dio.post(api, data: map);
      return SiluResponse(response.statusCode ?? 0, jsonDecode(response.data));
    } on DioError catch (e) {
      print('[Post Error] API($api) CODE(${e.response?.statusCode}) RSP(${e.response})');
      return SiluResponse(e.response?.statusCode ?? -1, e.response?.data);
    }
  }

  Future<Map<String, dynamic>?> uploadImgToOss(String category, Uint8List imageByte) async {
    final cachePath = u.cachePath;
    final srcImg = tpimg.decodeImage(imageByte)!;
    // 上传前池化
    var dstImg = srcImg.width > srcImg.height ? tpimg.copyResize(srcImg, width: 1280) : tpimg.copyResize(srcImg, height: 1280);
    final key = '${DateTime.now().toIso8601String()}-${u.uid}.jpg';
    // 本地写文件，避免日后下载缓存
    File('$cachePath/$key').writeAsBytesSync(tpimg.encodeJpg(dstImg));
    var rsp = await Bucket().postObject('$category/$key', '$cachePath/$key');
    return rsp.statusCode == HttpStatus.ok ? {'key': key, 'width': dstImg.width, 'height': dstImg.height} : null;
  }
}
