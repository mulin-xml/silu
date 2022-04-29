// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:silu/blog.dart';
import 'package:silu/pages/config_page.dart';
import 'package:silu/pages/edit_user_info_page.dart';
import 'package:silu/widgets/blog_view.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';
import 'package:silu/widgets/follow_button.dart';
import 'package:silu/widgets/follow_info_bar.dart';
import 'package:silu/widgets/user_topbar.dart';

class UserViewHeader extends StatefulWidget {
  const UserViewHeader(this.authorId, this.isSelf, {Key? key}) : super(key: key);

  final String authorId;
  final bool isSelf;

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
    return Stack(children: [
      Container(color: Colors.brown),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconView(_iconKey, size: 80),
                const SizedBox(width: 20),
                Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 30)),
              ],
            ),
            const SizedBox(height: 10),
            Text(_introduction, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // 左侧用于显示关注和粉丝数量
              FollowInfoBar(widget.authorId),
              // 右侧用于显示自己和别人的操作栏
              widget.isSelf ? selfOpBar() : otherOpBar(),
            ]),
          ],
        ),
      )
    ]);
  }

  final buttonStyle = OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    side: const BorderSide(color: Colors.white, width: 0.5),
  );

  Widget selfOpBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => EditUserInfoPage(_userName, _introduction, _iconKey))),
          child: const Text('编辑资料', style: TextStyle(color: Colors.white)),
          style: buttonStyle,
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const ConfigPage())),
          child: const Icon(Icons.settings, color: Colors.white),
          style: buttonStyle,
        ),
      ],
    );
  }

  Widget otherOpBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FollowButton(widget.authorId),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {},
          child: const Icon(Icons.message, color: Colors.white),
          style: buttonStyle,
        ),
      ],
    );
  }

  _getUserInfo() async {
    var userInfo = await getUserInfo(widget.authorId);
    if (userInfo != null) {
      setState(() {
        _userName = userInfo['username'];
        _introduction = userInfo['introduction'].replaceAll('\\n', '\n');
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

class _UserViewState extends State<UserView> with SingleTickerProviderStateMixin {
  final _releaseBlogs = <Widget>[];
  final _collectBlogs = <Widget>[];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    updatePage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant UserView oldWidget) {
    super.didUpdateWidget(oldWidget);
    updatePage();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      notificationPredicate: (notifation) => true,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              toolbarHeight: 0,
              expandedHeight: 220,
              flexibleSpace: FlexibleSpaceBar(
                background: UserViewHeader(widget.authorId, widget.isSelf),
                collapseMode: CollapseMode.pin,
              ),
            ),
            SliverAppBar(
              toolbarHeight: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.brown,
              pinned: true,
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.brown,
                indicatorWeight: 4,
                tabs: const [
                  Tab(text: '动态'),
                  Tab(text: '收藏'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [separatedListView(_releaseBlogs), separatedListView(_collectBlogs)],
          controller: _tabController,
        ),
      ),
      onRefresh: () async {
        updatePage();
      },
    );
  }

  Widget separatedListView(List<Widget> list) {
    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return index < list.length ? list[index] : Container();
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  updatePage() async {
    _releaseBlogs.clear();
    var data = {
      'offset': 0,
      'limit': 500,
      'login_user_id': u.uid,
      'search_type': 1,
      'search_user_id': widget.authorId,
    };
    var rsp = await SiluRequest().post('get_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok) {
      List activityList = rsp.data['activityList'];
      for (var elm in activityList) {
        _releaseBlogs.add(BlogItemView(Blog(elm), widget.isSelf));
      }
    }
    if (_releaseBlogs.isEmpty) {
      _releaseBlogs.add(noContentWidget);
    }

    _collectBlogs.clear();
    data = {
      'offset': 0,
      'limit': 500,
      'login_user_id': u.uid,
      'search_type': 4,
      'search_user_id': widget.authorId,
    };
    rsp = await SiluRequest().post('get_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok) {
      List activityList = rsp.data['activityList'];
      for (var elm in activityList) {
        _collectBlogs.add(BlogItemView(Blog(elm), widget.isSelf));
      }
    }
    if (_collectBlogs.isEmpty) {
      _collectBlogs.add(noContentWidget);
    }

    setState(() {});
  }

  final noContentWidget = Container(
    alignment: Alignment.center,
    child: const Text('暂无内容', textScaleFactor: 1.5),
    padding: const EdgeInsets.symmetric(vertical: 50),
  );
}