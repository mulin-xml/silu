// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dio/dio.dart';

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

  Future<SiluResponse> post(String api, Map<String, dynamic> map) async {
    try {
      var response = await _dio.post(api, data: FormData.fromMap(map));
      return SiluResponse(response.statusCode!, jsonDecode(response.toString()));
    } on DioError catch (e) {
      print(e.response.toString());
      return SiluResponse(e.response?.statusCode ?? -1, e.response.toString());
    }
  }
}
