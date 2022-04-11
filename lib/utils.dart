// ignore_for_file: avoid_print

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _cachePath = (await getTemporaryDirectory()).path;
    _sharedPreferences = await SharedPreferences.getInstance();
    print('Utils prepare ready.');
  }

  SharedPreferences get sharedPreferences => _sharedPreferences!;
  String get cachePath => _cachePath!;
}

var u = Utils();
