// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:silu/blog.dart';
import 'package:silu/widgets/build_blog_widget.dart';
import 'package:silu/event_bus.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

editUserInfo() async {
  var form = {
    'user_id': u.sharedPreferences.getString('user_id'),
    'new_username': '思路官方账号1',
  };
  var rsp = await SiluRequest().post('edit_user_info', form);
  print(rsp.data);
}

getUserInfo() async {
  var rsp = await SiluRequest().post('get_user_info', {'user_id': u.sharedPreferences.getString('user_id')});
  print(rsp.data);
}

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with AutomaticKeepAliveClientMixin {
  final _blogItems = <Widget>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    updatePage();
    bus.on('user_page_update', (arg) => updatePage());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.separated(
      itemCount: _blogItems.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const UserAccountsDrawerHeader(
            accountName: Text('3'),
            accountEmail: Text('4'),
            currentAccountPicture: CircleAvatar(child: FlutterLogo(size: 42.0)),
          );
        } else {
          return _blogItems[index - 1];
        }
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  _getMyBlogs() async {
    final sp = u.sharedPreferences;
    var data = {
      'offset': 0,
      'limit': 50,
      'login_user_id': sp.getString('user_id'),
      'search_user_id': sp.getString('user_id'),
    };
    var rsp = await SiluRequest().post('get_user_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok && rsp.data['status']) {
      List activityList = rsp.data['activityList'];
      for (var elm in activityList) {
        _blogItems.add(BuildBlogItem(Blog(elm)));
      }
    }
    setState(() {});
  }

  updatePage() {
    _blogItems.clear();
    _getMyBlogs();
  }
}
