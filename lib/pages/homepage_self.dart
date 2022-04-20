// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:silu/pages/config_page.dart';
import 'package:silu/pages/login_page.dart';

import 'package:silu/widgets/user_view.dart';
import 'package:silu/event_bus.dart';
import 'package:silu/utils.dart';

class SelfPage extends StatefulWidget {
  const SelfPage({Key? key}) : super(key: key);

  @override
  State<SelfPage> createState() => _SelfPageState();
}

class _SelfPageState extends State<SelfPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    updatePage();
    bus.on('self_page_update', (arg) => updatePage());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sp = u.sharedPreferences;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const ConfigPage()));
            },
          ),
        ],
      ),
      body: (sp.getBool('is_login') ?? false) ? UserView(sp.getString('user_id') ?? '-1', isSelf: true) : unLoginView(),
    );
  }

  Widget unLoginView() {
    return Column(children: [
      Container(
        height: 150,
        color: Colors.brown,
        padding: const EdgeInsets.all(20),
        child: const Text(
          '未登录',
          textScaleFactor: 1.5,
          style: TextStyle(color: Colors.white),
        ),
        alignment: Alignment.centerLeft,
      ),
      Expanded(
        child: Center(
          child: ElevatedButton(
            child: const Text('点击登录'),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const LoginPage()));
            },
          ),
        ),
      ),
    ]);
  }

  updatePage() {
    print('update');
    setState(() {});
  }
}
