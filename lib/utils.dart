// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silu/amap.dart';
import 'package:silu/http_manager.dart';

class Utils {
  static getInstance() => _instance;
  static final _instance = Utils._internal();
  factory Utils() => getInstance();
  Utils._internal() {
    _initAsync();
  }

  String? _cachePath;
  SharedPreferences? _sharedPreferences;

  _initAsync() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    AMap(); // AMap启动需要依赖sharedPreferences
    _cachePath = (await getTemporaryDirectory()).path;
    print('Utils prepare ready.');
  }

  SharedPreferences get sharedPreferences => _sharedPreferences!;
  String get cachePath => _cachePath!;
}

var u = Utils();

Future<Map<String, dynamic>?> getUserInfo(String userId) async {
  var rsp = await SiluRequest().post('get_user_info', {'user_id': userId});
  if (rsp.statusCode == HttpStatus.ok) {
    return rsp.data['userInfo'];
  } else {
    return null;
  }
}
