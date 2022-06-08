import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

class UserInfo {
  UserInfo.fromMap(Map<String, dynamic> map)
      : userName = map['username'],
        iconKey = map['icon_key'],
        introduction = map['introduction'],
        isFollowed = map['follow_status'];

  final String userName;
  final String iconKey;
  final String introduction;
  final bool isFollowed;
}

/// 用户信息内存级缓存
class UserInfoCache {
  static getInstance() => _instance;
  static final _instance = UserInfoCache._internal();
  factory UserInfoCache() => getInstance();
  UserInfoCache._internal();

  final _userInfoTbl = <int, UserInfo?>{};

  Future<UserInfo> cachedUserInfo(int targetUserId) async {
    if (!_userInfoTbl.containsKey(targetUserId)) {
      _userInfoTbl[targetUserId] = await _getUserInfo(targetUserId);
    }
    return Future.value(_userInfoTbl[targetUserId]);
  }

  Future<UserInfo> latestUserInfo(int targetUserId) async {
    _userInfoTbl[targetUserId] = await _getUserInfo(targetUserId);
    return Future.value(_userInfoTbl[targetUserId]);
  }

  Future<UserInfo?> _getUserInfo(int targetUserId) async {
    final rsp = await SiluRequest().post('get_user_info', {'target_user_id': targetUserId, 'login_user_id': u.uid});
    if (rsp.statusCode == SiluResponse.ok) {
      return UserInfo.fromMap(rsp.data['user_info']);
    } else {
      return null;
    }
  }
}
