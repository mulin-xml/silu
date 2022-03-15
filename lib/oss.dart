// ignore_for_file: avoid_print

// 用户登录名称 silu@1721203709818866.onaliyun.com
// 登录密码 cUb!MHCX(&g22xBAKIoL%il4hQMq2xhz
// AccessKey ID LTAI5tHGNaWaav3ifG5RJL8M
// AccessKey Secret rRPWittvDvkxICj9qwOgQ8RDBefj3c

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class Auth {
  Auth(this.accessKeyId, this.accessKetSecret);
  String accessKeyId;
  String accessKetSecret;

  String makeGetSignature(String date, String bucketName, String key) {
    var stringToSign = utf8.encode("GET\n\n\n$date\n/$bucketName/$key");
    return base64.encode(Hmac(sha1, utf8.encode(accessKetSecret)).convert(stringToSign).bytes);
  }

  String makePostSignature() {
    var policy = {"expiration": "2100-12-01T12:00:00.000Z", "conditions": []}.toString();
    return base64.encode(Hmac(sha1, utf8.encode(accessKetSecret)).convert(utf8.encode(policy)).bytes);
  }
}

class Bucket {
  Bucket._internal();
  static final _instance = Bucket._internal();
  factory Bucket() => getInstance();
  static getInstance() => _instance;

  static final _auth = Auth('LTAI5tHGNaWaav3ifG5RJL8M', 'rRPWittvDvkxICj9qwOgQ8RDBefj3c');
  static const _endpoint = 'http://silu-bucket.oss-cn-shanghai.aliyuncs.com';
  static const _bucketName = 'silu-bucket';
  static final _dio = Dio();

  getObject(String key, String filepath) async {
    String date = HttpDate.format(DateTime.now());
    _dio.options.headers = {
      'date': date,
      'authorization': 'OSS ' + _auth.accessKeyId + ':' + _auth.makeGetSignature(date, _bucketName, key),
    };
    var result = "";
    var isSucc = true;

    try {
      var response = await _dio.download(_endpoint + '/' + key, filepath);
      result = response.toString();
    } catch (e) {
      result = '[Error Catch]' + e.toString();
      isSucc = false;
    } finally {
      print(result);
    }
    return isSucc;
  }

  putObject(String key) async {
    String date = HttpDate.format(DateTime.now());
    jsonEncode({
      "expiration": "2050-12-01T12:00:00.000Z",
      "conditions": [
        ["content-length-range", 0, 1048576000],
      ],
    });
    var policy = base64Encode(utf8.encode('{"expiration": "2100-12-01T12:00:00.000Z","conditions": [["content-length-range", 0, 1048576000]]}'));
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    String path = image != null ? image.path : "";
    var formData = FormData.fromMap({
      "key": key,
      "success_action_status": 200,
      "OSSAccessKeyId": _auth.accessKeyId,
      "policy": policy,
      "Signature": base64.encode(Hmac(sha1, utf8.encode(_auth.accessKetSecret)).convert(utf8.encode(policy)).bytes),
      "file": await MultipartFile.fromFile(path),
    });

    var result = "";
    var isSucc = true;

    try {
      var response = await Dio().post(_endpoint, data: formData);
      print(response.statusCode);
      print(response.statusMessage);
    } on DioError catch (e) {
      result = '[Error Catch]' + e.toString();
      isSucc = false;
      print(e.response?.toString());
    } finally {
      print(result);
    }
    return isSucc;
  }
}
