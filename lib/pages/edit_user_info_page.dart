// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:silu/image_cache.dart';
import 'package:silu/utils.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/widgets/img_cropper.dart';

class EditUserInfoPage extends StatefulWidget {
  const EditUserInfoPage(this.iconKey, {Key? key}) : super(key: key);

  final String iconKey;

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
        title: const Text('编辑资料'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(children: [
        // 头像显示与编辑区域
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: GestureDetector(
              onTap: () async {
                var imageByte = await imgCropper(context, aspectRatio: 1);
                if (imageByte != null) {
                  final result = await SiluRequest().uploadImgToOss(OssImgCategory.icons, imageByte);
                  if (result != null) {
                    var data = {
                      'user_id': u.sharedPreferences.getString('user_id'),
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
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: widget.iconKey.isEmpty ? const FlutterLogo() : Image(image: OssImage(OssImgCategory.images, widget.iconKey), fit: BoxFit.cover),
                  width: 150,
                  height: 150,
                ),
                const Positioned(child: CircleAvatar(child: Icon(Icons.edit)), right: 0, bottom: 0)
              ]),
            ),
          ),
        ),
        const Divider(),
      ]),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: ElevatedButton(
            style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
            child: const Text('更新资料'),
            onPressed: editUserInfo,
          ),
        ),
      ),
    );
  }

  editUserInfo() async {}
}
