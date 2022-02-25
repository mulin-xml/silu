// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class UserImg {
  UserImg(
    this.path,
  )   : originImg = Image.file(File(path)),
        thumbImg = Image.file(File(path), fit: BoxFit.cover, width: 100);
  final String path;
  final Image originImg;
  final Image thumbImg;
}

class EditBlogPage extends StatefulWidget {
  const EditBlogPage({Key? key}) : super(key: key);

  @override
  _EditBlogPageState createState() => _EditBlogPageState();
}

class _EditBlogPageState extends State<EditBlogPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  static const _maxImgNum = 5;
  final _userImgList = <UserImg>[];

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
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
          // 图片列表
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: _userImgList.length + 1,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, final int physicIdx) {
                if (physicIdx == _userImgList.length) {
                  return Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (_userImgList.length >= _maxImgNum) {
                          Fluttertoast.showToast(msg: "最多只能有" + _maxImgNum.toString() + "张图哦");
                          return;
                        }
                        final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() => _userImgList.add(UserImg(image.path)));
                        }
                      },
                      child: const SizedBox(
                        width: 100,
                        child: Icon(Icons.add),
                      ),
                    ),
                  );
                } else {
                  return Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    clipBehavior: Clip.antiAlias,
                    child: _userImgList[physicIdx].thumbImg,
                  );
                }
              },
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: TextField(
              controller: _titleController,
              maxLength: 10,
              decoration: const InputDecoration(hintText: "标题有趣会有更多赞哦"),
            ),
          ),
          // 内容栏
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            child: Scrollbar(
              controller: scrollController,
              child: TextField(
                controller: _contextController,
                scrollController: scrollController,
                maxLines: 10,
                minLines: 1,
                decoration: const InputDecoration.collapsed(hintText: "说说此刻的心情吧"),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
      // 底部发布按钮
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(shape: const CircleBorder()),
                    onPressed: () {},
                    child: const Icon(Icons.storefront),
                  ),
                  const Text("存草稿", style: TextStyle(color: Colors.brown)),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                child: ElevatedButton(
                  style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
                  child: const Text('发布动态'),
                  onPressed: uploadBlog,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  uploadBlog() async {
    const url = 'http://0--0.top/apis/upload_activity';
    var result = "";
    final imgFiles = <MultipartFile>[];

    for (var elm in _userImgList) {
      // var name = elm.path.substring(elm.path.lastIndexOf("/") + 1, elm.path.length);
      imgFiles.add(await MultipartFile.fromFile(elm.path));
    }

    var formData = FormData.fromMap({
      'user_id': 'admin',
      'title': _titleController.text,
      'context': _contextController.text,
      'img_list': imgFiles,
    });

    try {
      var response = await Dio().post(url, data: formData);
      result = response.toString();
    } catch (e) {
      result = '[Error Catch]' + e.toString();
    }
    print(result);
    Fluttertoast.showToast(msg: result);
  }
}
