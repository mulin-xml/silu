// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

class FollowButton extends StatefulWidget {
  const FollowButton(this.userId, {Key? key}) : super(key: key);

  final String userId;

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  var isFollowed = false;

  @override
  void initState() {
    super.initState();
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    if (u.sharedPreferences.getString('user_id') == widget.userId) {
      return Container();
    }
    return Padding(padding: const EdgeInsets.all(5), child: isFollowed ? _followedButton() : _unFollowedButton());
  }

  Widget _unFollowedButton() {
    return ElevatedButton(
      onPressed: _followOperation,
      child: const Text('关注'),
      style: ButtonStyle(
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        elevation: MaterialStateProperty.all(0),
      ),
    );
  }

  Widget _followedButton() {
    return OutlinedButton(
      onPressed: _followOperation,
      child: const Text('已关注'),
      style: ButtonStyle(
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        elevation: MaterialStateProperty.all(0),
      ),
    );
  }

  _followOperation() async {
    final data = {
      'fan_id': u.sharedPreferences.getString('user_id') ?? '-1',
      'followed_user_id': widget.userId,
      'action': isFollowed ? 1 : 0,
    };
    await SiluRequest().post('follow', data);
    updateState();
  }

  updateState() async {
    var userInfo = await getUserInfo(widget.userId);
    setState(() {
      isFollowed = userInfo?['follow_status'] ?? false;
    });
  }
}
