// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silu/http_manager.dart';

editUserInfo() async {
  var form = {
    'user_id': '5',
    'new_username': '思路官方账号1',
  };
  var rsp = await SiluRequest().post('edit_user_info', form);
  print(rsp.data);
}

getUserInfo() async {
  var rsp = await SiluRequest().post('get_user_info', {'user_id': '5'});
  print(rsp.data);
}

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: Text("This is user info page."),
          ),
          ElevatedButton(
            style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
            child: const Text('清除缓存'),
            onPressed: clear,
          ),
        ],
      ),
    );
  }

  /// 清除缓存
  static clear() async {
    Directory tempDir = await getTemporaryDirectory();
    await _delete(tempDir);
  }

  /// 递归删除缓存目录和文件
  static _delete(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await _delete(child);
      }
    } else {
      await file.delete();
    }
  }
}
