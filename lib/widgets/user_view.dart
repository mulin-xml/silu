// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:silu/blog.dart';
import 'package:silu/widgets/blog_view.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';
import 'package:silu/widgets/user_topbar.dart';

class UserViewHeader extends StatefulWidget {
  const UserViewHeader(this.authorId, {Key? key}) : super(key: key);

  final String authorId;

  @override
  State<UserViewHeader> createState() => _UserViewHeaderState();
}

class _UserViewHeaderState extends State<UserViewHeader> {
  var _userName = '';
  var _introduction = '';
  var _iconKey = '';

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  void didUpdateWidget(covariant UserViewHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Text(_userName),
      accountEmail: Text(_introduction),
      currentAccountPicture: iconView(_iconKey),
      otherAccountsPictures: null,
      otherAccountsPicturesSize: const Size(100, 40),
    );
  }

  _getUserInfo() async {
    var userInfo = await getUserInfo(widget.authorId);
    if (userInfo != null) {
      setState(() {
        _userName = userInfo['username'];
        _introduction = userInfo['introduction'];
        _iconKey = userInfo['icon_key'];
      });
    }
  }
}

class UserView extends StatefulWidget {
  const UserView(this.authorId, {Key? key, this.isSelf = false}) : super(key: key);

  final String authorId;
  final bool isSelf;

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  final _blogItems = <Widget>[];

  @override
  void initState() {
    super.initState();
    updatePage();
  }

  @override
  void didUpdateWidget(covariant UserView oldWidget) {
    super.didUpdateWidget(oldWidget);
    updatePage();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _blogItems.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return UserViewHeader(widget.authorId);
          } else {
            return index - 1 < _blogItems.length ? _blogItems[index - 1] : Container();
          }
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
      onRefresh: () async {
        updatePage();
      },
    );
  }

  updatePage() async {
    _blogItems.clear();
    final sp = u.sharedPreferences;
    var data = {
      'offset': 0,
      'limit': 500,
      'login_user_id': (sp.getBool('is_login') ?? false) ? (sp.getString('user_id') ?? '-1') : '-1',
      'search_user_id': widget.authorId,
    };
    var rsp = await SiluRequest().post('get_user_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok) {
      List activityList = rsp.data['activityList'];
      for (var elm in activityList) {
        _blogItems.add(BlogItemView(Blog(elm), widget.isSelf));
      }
    }
    setState(() {});
  }
}
