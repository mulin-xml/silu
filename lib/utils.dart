// ignore_for_file: avoid_print

import 'package:path_provider/path_provider.dart';

class Utils {
  static getInstance() => _instance;
  static final _instance = Utils._internal();
  factory Utils() => getInstance();
  Utils._internal() {
    _initAsync();
  }

  String? cachePath;

  _initAsync() async {
    cachePath = (await getTemporaryDirectory()).path;
  }
}
