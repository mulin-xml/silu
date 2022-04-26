// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:silu/image_cache.dart';
import 'package:silu/utils.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/widgets/user_topbar.dart';
import 'package:silu/widgets/img_cropper.dart';

class EditUserInfoPage extends StatefulWidget {
  const EditUserInfoPage(this.username, this.introduction, this.iconKey, {Key? key}) : super(key: key);

  final String username;
  final String introduction;
  final String iconKey;

  @override
  State<EditUserInfoPage> createState() => _EditUserInfoPageState();
}

class _EditUserInfoPageState extends State<EditUserInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);
    _nameController.text = widget.username;
    _introductionController.text = widget.introduction;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        title: const Text('编辑资料'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
        sizedBoxSpace,
        // 头像显示与编辑区域
        Center(
          child: GestureDetector(
            onTap: () async {
              var imageByte = await imgCropper(context, aspectRatio: 1);
              if (imageByte != null) {
                final result = await SiluRequest().uploadImgToOss(OssImgCategory.icons, imageByte);
                if (result != null) {
                  var data = {
                    'user_id': u.uid,
                    'new_icon_key': result['key'],
                  };
                  final rsp = await SiluRequest().post('edit_user_info', data);
                  if (rsp.statusCode == HttpStatus.ok) {
                    Fluttertoast.showToast(msg: '头像更新成功');
                  } else {
                    Fluttertoast.showToast(msg: '头像更新失败');
                  }
                } else {
                  print('OSS上传失败');
                }
              }
            },
            child: Stack(children: [
              SizedBox(width: 150, height: 150, child: iconView(widget.iconKey)),
              const Positioned(child: CircleAvatar(child: Icon(Icons.edit)), right: 0, bottom: 0),
            ]),
          ),
        ),
        sizedBoxSpace,
        // 名字
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          maxLength: 20,
          decoration: const InputDecoration(
            filled: true,
            icon: Icon(Icons.person),
            hintText: '添加一个名字',
            labelText: '名字',
          ),
        ),
        sizedBoxSpace,
        // 个人简介
        TextFormField(
          controller: _introductionController,
          textCapitalization: TextCapitalization.words,
          maxLength: 100,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '有趣的简介可以吸引粉丝',
            labelText: '个人简介',
          ),
          maxLines: 5,
        ),
        const Divider(indent: 10, endIndent: 10, thickness: 0.1),
      ]),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text('更新资料'),
            onPressed: _editUserInfo,
          ),
        ),
      ),
    );
  }

  _editUserInfo() async {
    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: '名字不能为空哦');
      return;
    }
    var data = {
      'user_id': u.uid,
      'new_username': _nameController.text,
      'new_introduction': _introductionController.text.replaceAll('\n', '\\n'),
    };
    final rsp = await SiluRequest().post('edit_user_info', data);
    if (rsp.statusCode == HttpStatus.ok) {
      Fluttertoast.showToast(msg: '资料更新成功');
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(msg: '资料更新失败');
    }
  }
}
