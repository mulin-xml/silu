// ignore_for_file: avoid_print

// 用户登录名称 silu@1721203709818866.onaliyun.com
// 登录密码 cUb!MHCX(&g22xBAKIoL%il4hQMq2xhz
// AccessKey ID LTAI5tHGNaWaav3ifG5RJL8M
// AccessKey Secret rRPWittvDvkxICj9qwOgQ8RDBefj3c

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
// import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class Auth {
  Auth(this.accessKeyId, this.accessKetSecret);
  String accessKeyId;
  String accessKetSecret;

  String makeSignature(String date) {
    var a = utf8.encode(date);
    return base64.encode(Hmac(sha1, utf8.encode(accessKetSecret)).convert(a).bytes);
  }
}

class Bucket {
  Bucket(this.auth, this.endpoint);
  Auth auth;
  String endpoint;

  getObject(String key, String filename) async {
    var dio = Dio();

    String date = HttpDate.format(DateTime.now());
    print(auth.makeSignature('Tue, 15 Mar 2022 07:14:14 GMT'));

    return;
    dio.options.headers = {
      'date': 'Tue, 15 Mar 2022 07:14:14 GMT',
      'authorization': 'OSS ' + auth.accessKeyId + ':' + '0lLlUXmOlUYN/lhxoZ5pg8xM81Q=',
    };
    var result = "";
    var isSucc = true;

    try {
      var response = await dio.get(endpoint + '/' + key);
      // var response = await dio.download(url, filename);
      result = response.toString();
    } catch (e) {
      result = '[Error Catch]' + e.toString();
      isSucc = false;
    } finally {
      print(result.length);
      print(result);
    }
  }
}

func() async {
  var auth = Auth('LTAI5tHGNaWaav3ifG5RJL8M', 'rRPWittvDvkxICj9qwOgQ8RDBefj3c');
  var bucket = Bucket(auth, 'http://silu-bucket.oss-cn-shanghai.aliyuncs.com');
  var cachePath = (await getTemporaryDirectory()).path;
  bucket.getObject('123.jpg', '$cachePath/123.jpg');
}
