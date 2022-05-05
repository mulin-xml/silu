// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:silu/global_declare.dart';
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
  final _viewItems = <Blog>[];

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
        child: separatedListView(_viewItems, false),
        onRefresh: () async {
          updatePage();
        },
      ),
    );
  }

  updatePage() async {
    _viewItems.clear();
    var data = {
      'offset': 0,
      'limit': 500,
      'login_user_id': u.uid,
      'search_type': 2,
    };
    var rsp = await SiluRequest().post('get_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok) {
      List activityList = rsp.data['activityList'];
      for (Map<String, dynamic> elm in activityList) {
        _viewItems.add(Blog(elm));
      }
    }

    setState(() {});
  }
}
