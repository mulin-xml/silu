// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:image/image.dart' as tpimg;
import 'package:silu/amap.dart';
import 'package:silu/oss.dart';
import 'package:silu/utils.dart';
import 'package:silu/http_manager.dart';

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
  var _isBlogLongTime = false;
  var _blogAccessTime = '';

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
              maxLength: 40,
              decoration: const InputDecoration(hintText: "标题有趣会有更多赞哦", counterText: ""),
            ),
          ),
          // 内容栏
          Container(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
            child: Scrollbar(
              controller: scrollController,
              child: TextField(
                controller: _contextController,
                scrollController: scrollController,
                maxLines: 10,
                minLines: 5,
                decoration: const InputDecoration.collapsed(hintText: "说说此刻的心情吧"),
              ),
            ),
          ),
          const Divider(indent: 10, endIndent: 10, thickness: 0.1),
          // 位置选择
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('位置选择'),
            trailing: const Icon(Icons.chevron_right),
            subtitle: Text(AMap().location['address'].toString()),
          ),
          const Divider(indent: 10, endIndent: 10, thickness: 0.1),
          // 日期选择器
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('动态有效时间'),
            subtitle: Text(_blogAccessTime),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _isBlogLongTime,
                  onChanged: (value) => setState(() {
                    _isBlogLongTime = !_isBlogLongTime;
                    _blogAccessTime = _isBlogLongTime ? '' : _blogAccessTime;
                  }),
                ),
                const Text('长期', style: TextStyle(color: Colors.brown)),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () async {
              var date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100), locale: const Locale('zh'));
              setState(() {
                _blogAccessTime = date?.toString().substring(0, 10) ?? '';
                _isBlogLongTime = date == null;
              });
            },
          ),
          const Divider(indent: 10, endIndent: 10, thickness: 0.1),
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
    final sp = Utils().sharedPreferences;
    if (sp.getString('user_id')?.isEmpty ?? false) {
      Fluttertoast.showToast(msg: '获取用户信息失败');
      return;
    } else if (_titleController.text.isEmpty || _contextController.text.isEmpty || _userImgList.isEmpty) {
      Fluttertoast.showToast(msg: '内容不能为空哦');
      return;
    }

    // 图片上传OSS
    final userId = sp.getString('user_id') ?? '';
    final cachePath = Utils().cachePath;
    final imgInfoList = <Map<String, dynamic>>[];
    for (var elm in _userImgList) {
      final img = tpimg.decodeImage(elm.imageByte)!;
      final key = '${DateTime.now().toIso8601String()}-$userId.jpg';
      File('$cachePath/$key').writeAsBytesSync(tpimg.encodeJpg(img));
      final rsp = await Bucket().postObject('images/$key', '$cachePath/$key');
      if (rsp.statusCode == HttpStatus.ok) {
        imgInfoList.add({'key': key, 'width': img.width, 'height': img.height});
      } else {
        print('OSS上传$key失败');
      }
    }

    var data = {
      'user_id': userId,
      'title': _titleController.text,
      'context': _contextController.text.replaceAll('\n', '\\n'),
      'oss_img_list': imgInfoList,
      'location': AMap().location,
      'activity_type': 0,
      'access_time': _blogAccessTime,
    };
    var rsp = await SiluRequest().post('upload_activity', data);
    if (rsp.statusCode == HttpStatus.ok && rsp.data['status']) {
      Fluttertoast.showToast(msg: '上传成功');
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(msg: '上传失败，请检查网络');
    }
  }
}
