import 'dart:io';
import 'package:dio/dio.dart';

class HttpManager {
  HttpManager()
      : options = BaseOptions(
          baseUrl: 'http://0--0.top/apis',
          connectTimeout: 5000,
          receiveTimeout: 3000,
        ),
        _dio = Dio();
  Dio _dio;
  BaseOptions options;
  static HttpManager? _instance;
  static HttpManager? getInstance() {
    _instance ??= HttpManager();
    return _instance;
  }
}
