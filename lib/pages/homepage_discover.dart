// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:silu/amap.dart';

import 'package:silu/blog.dart';
import 'package:silu/widgets/blog_view.dart';
import 'package:silu/event_bus.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with AutomaticKeepAliveClientMixin {
  final _blogs = <Blog>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (amap.isLocated) {
      updatePage();
    } else {
      bus.on('discover_page_update', (arg) => updatePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      child: MasonryGridView.count(
        crossAxisCount: 2,
        itemCount: _blogs.length,
        addAutomaticKeepAlives: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return index < _blogs.length ? BlogCardView(_blogs[index]) : Container();
        },
      ),
      onRefresh: () async {
        updatePage();
      },
    );
  }

  _getBatchBlogs() async {
    final sp = u.sharedPreferences;
    var data = {
      'offset': 0,
      'limit': 500,
      'login_user_id': (sp.getBool('is_login') ?? false) ? sp.getString('user_id') : '-1',
    };
    var rsp = await SiluRequest().post('get_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok) {
      List activityList = rsp.data['activityList'];
      for (Map<String, dynamic> elm in activityList) {
        _blogs.add(Blog(elm));
      }
    }
    setState(() {});
  }

  updatePage() {
    _blogs.clear();
    _getBatchBlogs();
  }
}
