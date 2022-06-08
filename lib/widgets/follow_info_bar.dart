// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:silu/event_bus.dart';

import 'package:silu/http_manager.dart';
import 'package:silu/pages/user_page.dart';
import 'package:silu/utils.dart';
import 'package:silu/widgets/user_topbar.dart';

class FollowInfoBar extends StatefulWidget {
  const FollowInfoBar(this.userId, {Key? key}) : super(key: key);

  final int userId;

  @override
  State<FollowInfoBar> createState() => _FollowInfoBarState();
}

class _FollowInfoBarState extends State<FollowInfoBar> {
  var _followList = [];
  var _fanList = [];

  @override
  void initState() {
    super.initState();
    updateState();
    bus.on('user_view_update', (arg) {
      if (arg == widget.userId) {
        updateState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        grid('关注', _followList),
        const SizedBox(width: 40),
        grid('粉丝', _fanList),
      ],
    );
  }

  Widget grid(String name, List list) {
    return GestureDetector(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(list.length.toString(), style: const TextStyle(color: Colors.white)),
          Text(name, style: const TextStyle(color: Colors.white)),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ShowListPage(name, list))),
    );
  }

  updateState() async {
    print('[State] FollowInfoBar update.');
    var rsp = await SiluRequest().post('get_follow_list', {'target_user_id': widget.userId, 'login_user_id': u.uid, 'search_type': 0});
    if (rsp.statusCode == SiluResponse.ok) {
      _fanList = rsp.data['user_info_list'];
    }
    rsp = await SiluRequest().post('get_follow_list', {'target_user_id': widget.userId, 'login_user_id': u.uid, 'search_type': 1});
    if (rsp.statusCode == SiluResponse.ok) {
      _followList = rsp.data['user_info_list'];
    }
    setState(() {});
  }
}

class ShowListPage extends StatelessWidget {
  const ShowListPage(this.title, this.list, {Key? key}) : super(key: key);

  final String title;
  final List list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        title: Text(title),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: iconView(list[index]['icon_key']),
            title: Text(list[index]['username']),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => userPage(list[index]['id'].toString()))),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
