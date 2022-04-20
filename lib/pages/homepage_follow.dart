// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:silu/blog.dart';
import 'package:silu/widgets/appbar_view.dart';
import 'package:silu/widgets/blog_view.dart';
import 'package:silu/event_bus.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({Key? key}) : super(key: key);

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> with AutomaticKeepAliveClientMixin {
  final _viewItems = <Widget>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    updatePage();
    bus.on('follow_page_update', (arg) => updatePage());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: appBarView('关注'),
      body: RefreshIndicator(
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: _viewItems.length,
          itemBuilder: (context, index) {
            return index < _viewItems.length ? _viewItems[index] : Container();
          },
          separatorBuilder: (context, index) => const Divider(),
        ),
        onRefresh: () async {
          updatePage();
        },
      ),
    );
  }

  updatePage() async {
    _viewItems.clear();
    final sp = u.sharedPreferences;
    var data = {
      'offset': 0,
      'limit': 500,
      'login_user_id': sp.getString('user_id') ?? '-1',
    };
    var rsp = await SiluRequest().post('get_follow_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok) {
      List activityList = rsp.data['activityList'];
      for (Map<String, dynamic> elm in activityList) {
        _viewItems.add(BlogItemView(Blog(elm), false));
      }
    }
    if (_viewItems.isEmpty) {
      _viewItems.add(const Center(child: Text('还没有关注的内容哦', textScaleFactor: 1.2)));
    }
    setState(() {});
  }
}
