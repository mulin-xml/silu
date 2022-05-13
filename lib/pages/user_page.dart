// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:silu/pages/config_page.dart';
import 'package:silu/widgets/user_view.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
      body: UserView(u.uid, isSelf: true),
    );
  }
}

userPage(userId) {
  return Scaffold(
    appBar: AppBar(
      toolbarHeight: 44,
      elevation: 0,
    ),
    body: UserView(userId),
  );
}
