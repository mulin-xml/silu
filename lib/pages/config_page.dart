// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silu/pages/edit_user_info_page.dart';
import 'package:silu/pages/login_page.dart';
import 'package:silu/utils.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  @override
  Widget build(BuildContext context) {
    final sp = u.sharedPreferences;
    final bool isLogin = sp.getBool('is_login') ?? false;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(children: [
        ListTile(
          title: Text(isLogin ? '编辑资料' : '未登录'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => isLogin ? EditUserInfoPage(sp.getString('user_id') ?? '-1') : const LoginPage()));
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('清除缓存'),
          onTap: () async {
            Directory tempDir = await getTemporaryDirectory();
            final List<FileSystemEntity> children = tempDir.listSync();
            for (final FileSystemEntity child in children) {
              print(child.path);
              await child.delete();
            }
            Fluttertoast.showToast(msg: '已清除');
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('退出登录'),
          onTap: () {
            Navigator.pop(context);
            signOut();
          },
        ),
      ]),
    );
  }
}
