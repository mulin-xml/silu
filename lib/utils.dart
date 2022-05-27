// ignore_for_file: avoid_print

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

  String _downloadUrl = '';
  Future<bool>? _isUpdateNecessary;

  Future<bool> _versionCheck() async {
    final rsp = await SiluRequest().get('get_version_info');
    if (rsp.statusCode != SiluResponse.ok) {
      return false; // 联网失败，不强制更新
    }
    _downloadUrl = rsp.data['version_info']['download_url'];
    final String localVersion = (await PackageInfo.fromPlatform()).version;
    if (localVersion.compareTo(rsp.data['version_info']['support_min_version']).isNegative) {
      return true;
    }
    return false;
  }

  Future<bool> get isUpdateNecessary => _isUpdateNecessary!;
  String get downloadUrl => _downloadUrl;
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
  String get uid => sharedPreferences.getString('user_id') ?? '-1';
}

final u = Utils();

Future<Map<String, dynamic>?> getUserInfo(String targetUserId) async {
  final data = {
    'target_user_id': targetUserId,
    'login_user_id': u.uid,
  };
  var rsp = await SiluRequest().post('get_user_info', data);
  if (rsp.statusCode == SiluResponse.ok) {
    return rsp.data['user_info'];
  } else {
    return null;
  }
}
