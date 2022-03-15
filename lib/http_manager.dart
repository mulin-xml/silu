import 'dart:io';
import 'package:dio/dio.dart';

class HttpManager {
  HttpManager._internal()
      : options = BaseOptions(
          baseUrl: 'http://0--0.top/apis',
          connectTimeout: 5000,
          receiveTimeout: 3000,
        ),
        _dio = Dio();

  Dio _dio;
  BaseOptions options;
  static final _instance = HttpManager._internal();
  factory HttpManager() => getInstance();
  static getInstance() {
    return _instance;
  }
}
