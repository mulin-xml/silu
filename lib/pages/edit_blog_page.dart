// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';

import 'package:silu/amap.dart';
import 'package:silu/utils.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/widgets/amap_view.dart';

class EditBlogPage extends StatefulWidget {
  const EditBlogPage({Key? key}) : super(key: key);

  @override
  _EditBlogPageState createState() => _EditBlogPageState();
}

class _EditBlogPageState extends State<EditBlogPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  static const _maxImgNum = 9;
  final _imgList = <Uint8List>[];
  var _isBlogLongTime = false;
  var _blogAccessTime = '';
  var _address = AMap().location['address'].toString();
  var _latLng = AMap().lastLatLng;

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 图片列表
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: _imgList.length + 1,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return (index == _imgList.length) ? _addImgCard() : _imgCard(index);
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
            subtitle: Text(_address),
            onTap: () async {
              var result = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const AMapView()));
              if (result?[0] != null) {
                setState(() {
                  _latLng = result[0];
                  _address = result[1];
                });
              }
            },
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

  _imgCard(int index) {
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
                          return Image.memory(_imgList[index]);
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
                          setState(() => _imgList.removeAt(index));
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              ),
          child: Image.memory(_imgList[index], fit: BoxFit.cover, width: 100)),
    );
  }

  _addImgCard() {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (_imgList.length >= _maxImgNum) {
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
                        Navigator.of(context).pop(image);
                      },
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
              setState(() => _imgList.add(img));
            }
          }
        },
        child: const SizedBox(
          width: 100,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  uploadBlog() async {
    final sp = u.sharedPreferences;
    // 检查内容是否合法
    if (sp.getString('user_id')?.isEmpty ?? false) {
      Fluttertoast.showToast(msg: '获取用户信息失败');
      return;
    } else if (_titleController.text.isEmpty || _contextController.text.isEmpty || _imgList.isEmpty) {
      Fluttertoast.showToast(msg: '内容不能为空哦');
      return;
    }

    // 图片上传OSS
    final userId = sp.getString('user_id') ?? '';
    final imgInfoList = <Map<String, dynamic>>[];
    for (var elm in _imgList) {
      var result = await SiluRequest().uploadImgToOss(OssImgCategory.images, elm);
      if (result != null) {
        imgInfoList.add(result);
      } else {
        print('OSS上传失败');
      }
    }

    // 表单上传后端
    var data = {
      'user_id': userId,
      'title': _titleController.text,
      'context': _contextController.text.replaceAll('\n', '\\n'),
      'oss_img_list': imgInfoList,
      'location': {
        'latitude': _latLng.latitude,
        'longitude': _latLng.longitude,
        'address': _address,
      },
      'activity_type': 0,
      'access_time': _blogAccessTime,
    };
    var rsp = await SiluRequest().post('upload_activity', data);
    if (rsp.statusCode == HttpStatus.ok) {
      Fluttertoast.showToast(msg: '上传成功');
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(msg: '上传失败，请检查网络');
    }
  }
}
