// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:silu/amap.dart';
import 'package:silu/http_manager.dart';

class VersionCheck {
  static getInstance() => _instance;
  static final _instance = VersionCheck._internal();
  factory VersionCheck() => getInstance();
  VersionCheck._internal() {
    _isUpdateNecessary = _versionCheck();
  }

  String _localVersion = '';
  String? _latestVersion;
  String? _downloadUrl;
  Future<bool>? _isUpdateNecessary;

  Future<bool> _versionCheck() async {
    _localVersion = (await PackageInfo.fromPlatform()).version;
    final rsp = await SiluRequest().get('get_version_info');
    if (rsp.statusCode != SiluResponse.ok) {
      print('[Version Error] LOCAL($localVersion)');
      return false; // 联网失败，不强制更新
    }
    final data = jsonDecode(rsp.data);
    _latestVersion = data['version_info']['latest_version'];
    _downloadUrl = data['version_info']['download_url'];
    return _isVersionIllegal(localVersion, data['version_info']['support_min_version']);
  }

  bool _isVersionIllegal(String localVersion, String supportMinVersion) {
    final localVersions = localVersion.split('.');
    final remoteVersions = supportMinVersion.split('.');
    if (localVersions.length != 3 || remoteVersions.length != 3) {
      print('[Version Error] LOCAL($localVersion) REMOTE($supportMinVersion)');
      return false; // 版本判断失败，不强制更新
    }
    for (var i = 0; i < 3; i++) {
      if (int.parse(localVersions[i]) < int.parse(remoteVersions[i])) {
        return true; // 当前版本不满足后端所支持的最低版本，强制更新
      }
    }
    return false; // 当前版本合法，继续使用
  }

  Future<bool> get isUpdateNecessary => _isUpdateNecessary!;
  String? get downloadUrl => _downloadUrl;
  String? get latestVersion => _latestVersion;
  String get localVersion => _localVersion;
}

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
    VersionCheck();
    AMap(); // AMap启动需要依赖sharedPreferences
    _cachePath = (await getTemporaryDirectory()).path;
    print('Utils prepare ready.');
  }

  SharedPreferences get sharedPreferences => _sharedPreferences!;
  String get cachePath => _cachePath!;
  int get uid => sharedPreferences.getInt('login_user_id') ?? -1;
  bool get isLogin => !uid.isNegative;
}

final u = Utils();
