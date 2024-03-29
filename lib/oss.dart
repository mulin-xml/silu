// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as tpimg;

import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

class Auth {
  Auth(this.accessKeyId, this.accessKetSecret);
  String accessKeyId;
  String accessKetSecret;

  String makeGetSignature(String date, String bucketName, String key) {
    var stringToSign = utf8.encode("GET\n\n\n$date\n/$bucketName/$key");
    return base64.encode(Hmac(sha1, utf8.encode(accessKetSecret)).convert(stringToSign).bytes);
  }

  String makePostSignature(String policy) {
    return base64.encode(Hmac(sha1, utf8.encode(accessKetSecret)).convert(utf8.encode(policy)).bytes);
  }
}

// 单例模式
class Bucket {
  Bucket._internal();
  static final _instance = Bucket._internal();
  factory Bucket() => getInstance();
  static getInstance() => _instance;

  static final _auth = Auth('LTAI5tHGNaWaav3ifG5RJL8M', 'rRPWittvDvkxICj9qwOgQ8RDBefj3c');
  static const _endpoint = 'http://silu-bucket.oss-cn-shanghai.aliyuncs.com';
  static const _bucketName = 'silu-bucket';
  static final _dio = Dio();

  Future<SiluResponse> getObject(String key, String filepath) async {
    String date = HttpDate.format(DateTime.now());
    try {
      var response = await _dio.download('$_endpoint/$key', filepath,
          options: Options(headers: {'date': date, 'authorization': 'OSS ' + _auth.accessKeyId + ':' + _auth.makeGetSignature(date, _bucketName, key)}));
      return SiluResponse(response.statusCode ?? 0, null);
    } on DioError catch (e) {
      return SiluResponse(e.response?.statusCode ?? -1, e.response?.data);
    }
  }

  Future<SiluResponse> postObject(String key, filepath) async {
    final policy = base64Encode(utf8.encode(jsonEncode({
      "expiration": "2050-12-01T12:00:00.000Z",
      "conditions": [
        ["content-length-range", 0, 1048576000],
      ],
    })));

    final formData = FormData.fromMap({
      "key": key,
      "success_action_status": 200,
      "OSSAccessKeyId": _auth.accessKeyId,
      "policy": policy,
      "Signature": _auth.makePostSignature(policy),
      "file": await MultipartFile.fromFile(filepath),
    });

    try {
      var response = await _dio.post(_endpoint, data: formData);
      return SiluResponse(response.statusCode ?? 0, null);
    } on DioError catch (e) {
      return SiluResponse(e.response?.statusCode ?? -1, e.response?.data);
    }
  }

  Future<Map<String, dynamic>?> uploadImg(String category, Uint8List imageByte) async {
    final cachePath = u.cachePath;
    final srcImg = tpimg.decodeImage(imageByte)!;
    final dstImg = srcImg.width > srcImg.height ? tpimg.copyResize(srcImg, width: 1280) : tpimg.copyResize(srcImg, height: 1280); // 上传前池化
    final key = '${DateTime.now().toIso8601String()}-${u.uid}.jpg';

    File('$cachePath/$key').writeAsBytesSync(tpimg.encodeJpg(dstImg)); // 本地写文件，避免日后下载缓存
    var rsp = await Bucket().postObject('$category/$key', '$cachePath/$key');
    return rsp.statusCode == SiluResponse.ok ? {'key': key, 'width': dstImg.width, 'height': dstImg.height} : null;
  }
}
