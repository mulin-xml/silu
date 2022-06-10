// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:silu/http_manager.dart';
import 'package:silu/user_info_cache.dart';
import 'package:silu/utils.dart';

class FollowButton extends StatefulWidget {
  const FollowButton(this.userId, {Key? key}) : super(key: key);

  final int userId;

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  var _isFollowed = false;

  @override
  Widget build(BuildContext context) {
    if (u.uid == widget.userId) return Container();
    return Padding(
      padding: const EdgeInsets.all(5),
      child: FutureBuilder<UserInfo>(
        future: UserInfoCache().latestUserInfo(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _isFollowed = snapshot.data?.isFollowed ?? false;
            return _isFollowed ? _followedButton() : _unFollowedButton();
          }
          return _unFollowedButton();
        },
      ),
    );
  }

  Widget _unFollowedButton() {
    return ElevatedButton(
      onPressed: _followOperation,
      child: const Text('关注', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
        side: const BorderSide(width: 0.5, color: Colors.white),
      ),
    );
  }

  Widget _followedButton() {
    return OutlinedButton(
      onPressed: _followOperation,
      child: const Text('已关注', style: TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
        backgroundColor: Colors.grey.withOpacity(0.5),
        side: const BorderSide(width: 0.5, color: Colors.white),
      ),
    );
  }

  _followOperation() async {
    await SiluRequest().post('follow', {'fan_id': u.uid, 'followed_user_id': widget.userId, 'action': _isFollowed ? 1 : 0});
    setState(() {});
  }
}
