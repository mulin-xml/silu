// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:silu/amap.dart';
import 'package:silu/global_declare.dart';
import 'package:silu/widgets/appbar_view.dart';
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
    return Scaffold(
      appBar: appBarView('思路'),
      body: RefreshIndicator(
        child: waterfallListView(_blogs),
        onRefresh: () async {
          updatePage();
        },
      ),
    );
  }

  _getBatchBlogs() async {
    var data = {
      'offset': 0,
      'limit': 500,
      'login_user_id': u.uid,
      'search_type': 0,
    };
    var rsp = await SiluRequest().post('get_activity_list', data);
    if (rsp.statusCode == SiluResponse.ok) {
      List activityList = rsp.data['activity_list'];
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
