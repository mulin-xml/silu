// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
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
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: Text("This is user info page."),
          ),
        ],
      ),
    );
  }
}
