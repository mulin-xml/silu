// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:silu/utils.dart';
import 'package:silu/http_manager.dart';

class EditUserInfoPage extends StatefulWidget {
  const EditUserInfoPage({Key? key}) : super(key: key);

  @override
  State<EditUserInfoPage> createState() => _EditUserInfoPageState();
}

class _EditUserInfoPageState extends State<EditUserInfoPage> {
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
      body: const Text('测试页面'),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: ElevatedButton(
            style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
            child: const Text('更新头像'),
            onPressed: editUserInfo,
          ),
        ),
      ),
    );
  }

  editUserInfo() async {
    // 图片上传OSS
    Uint8List? imageByte = await (await ImagePicker().pickImage(source: ImageSource.gallery))?.readAsBytes();
    if (imageByte != null) {
      final result = await SiluRequest().uploadImgToOss(OssImgCategory.icons, imageByte);
      if (result != null) {
        // 表单上传后端
        var data = {
          'user_id': u.sharedPreferences.getString('user_id'),
          'new_introduction': 'lalala',
          'new_icon_key': result['key'],
        };
        final rsp = await SiluRequest().post('edit_user_info', data);
        if (rsp.statusCode == HttpStatus.ok) {
          Fluttertoast.showToast(msg: '资料更新成功');
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(msg: '资料更新失败');
        }
      } else {
        print('OSS上传失败');
      }
    }
  }
}
