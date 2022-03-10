// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';

class UserImg {
  UserImg(
    this.imageByte,
  ) : thumbImg = Image.memory(imageByte, fit: BoxFit.cover, width: 100);
  final Uint8List imageByte;
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
                  // 添加图片按钮
                  return Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (_userImgList.length >= _maxImgNum) {
                          Fluttertoast.showToast(msg: "最多只能有" + _maxImgNum.toString() + "张图哦");
                          return;
                        }
                        Uint8List? imageByte = await (await ImagePicker().pickImage(source: ImageSource.gallery))?.readAsBytes();
                        if (imageByte != null) {
                          var img = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                            final _controller = CropController();
                            return Column(
                              children: [
                                Expanded(
                                  child: Crop(
                                    image: imageByte,
                                    controller: _controller,
                                    onCropped: (image) {
                                      Navigator.of(context).pop(UserImg(image));
                                    },
                                    initialSize: 0.8,
                                    withCircleUi: false,
                                    baseColor: Colors.black,
                                    maskColor: Colors.black.withAlpha(150),
                                    cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.white54),
                                  ),
                                ),
                                ElevatedButton(
                                  child: const Text("选择图片"),
                                  onPressed: () => _controller.crop(),
                                ),
                              ],
                            );
                          }));
                          if (img != null) {
                            setState(() => _userImgList.add(img));
                          }
                        }
                      },
                      child: const SizedBox(
                        width: 100,
                        child: Icon(Icons.add),
                      ),
                    ),
                  );
                } else {
                  // 呈现图片
                  return Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    clipBehavior: Clip.antiAlias,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            children: [
                              SimpleDialogOption(
                                child: const Text(
                                  '预览图片',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
                                  return Image.memory(_userImgList[physicIdx].imageByte);
                                })),
                              ),
                              const Divider(),
                              SimpleDialogOption(
                                child: const Text(
                                  '删除图片',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _userImgList.removeAt(physicIdx);
                                  });

                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      child: _userImgList[physicIdx].thumbImg,
                    ),
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
              maxLength: 50,
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
    if (_titleController.text.isEmpty || _contextController.text.isEmpty) {
      Fluttertoast.showToast(msg: '内容不能为空哦');
      return;
    }
    const url = 'http://0--0.top/apis/upload_activity';
    var result = "";
    final imgs = [];

    for (var elm in _userImgList) {
      imgs.add(base64.encode(elm.imageByte));
    }

    var formData = dio.FormData.fromMap({
      'user_id': '5',
      'title': _titleController.text,
      'context': _contextController.text,
      'img_list': imgs,
    });

    try {
      var response = await dio.Dio().post(url, data: formData);
      result = response.toString();
    } catch (e) {
      result = '[Error Catch]' + e.toString();
    }
    print(result);
    Fluttertoast.showToast(msg: result);
  }
}
