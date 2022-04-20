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
    final isLogin = sp.getBool('is_login') ?? false;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        title: const Text('设置'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          commonItem(
            title: '账号与资料',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => isLogin ? EditUserInfoPage(sp.getString('user_id') ?? '-1') : const LoginPage()));
            },
          ),
          const Divider(),
          commonItem(
            title: '清除缓存',
            onTap: () async {
              Directory tempDir = await getTemporaryDirectory();
              final List<FileSystemEntity> children = tempDir.listSync();
              Fluttertoast.showToast(msg: '已清除${children.length}项缓存文件');
              for (final FileSystemEntity child in children) {
                print(child.path);
                await child.delete();
              }
            },
          ),
          const Divider(),
          commonItem(title: '关于思路'),
          const SizedBox(height: 50),
          isLogin
              ? ElevatedButton(
                  style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
                  child: const Text('退出登录'),
                  onPressed: () {},
                )
              : Container(),
        ],
      ),
    );
  }

  Widget commonItem({String? title, onTap}) {
    return ListTile(
      title: Text(title ?? ''),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
