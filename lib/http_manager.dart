// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:dio/dio.dart';

class SiluResponse {
  SiluResponse(this.statusCode, this.data);
  int statusCode;
  dynamic data;

  static const ok = 200;
}

class SiluRequest {
  static getInstance() => _instance;
  static final _instance = SiluRequest._internal();
  factory SiluRequest() => getInstance();
  SiluRequest._internal();
  static final _dio = Dio(BaseOptions(baseUrl: 'http://0--0.top/apis/'));

  Future<SiluResponse> get(String api) async {
    try {
      final response = await _dio.get(api);
      return SiluResponse(response.statusCode ?? 0, response.data);
    } on DioError catch (e) {
      print('[Get Error] API($api) CODE(${e.response?.statusCode}) RSP(${e.response})');
      return SiluResponse(e.response?.statusCode ?? -1, e.response?.data);
    }
  }

  Future<SiluResponse> post(String api, dynamic map) async {
    try {
      final response = await _dio.post(api, data: map);
      print('[Post] API($api) RSPTYPE(${response.data.runtimeType})');
      return SiluResponse(response.statusCode ?? 0, jsonDecode(response.data));
    } on DioError catch (e) {
      print('[Post Error] API($api) CODE(${e.response?.statusCode}) RSP(${e.response})');
      return SiluResponse(e.response?.statusCode ?? -1, e.response?.data);
    }
  }
}
