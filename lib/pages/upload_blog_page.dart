// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import 'package:silu/amap.dart';
import 'package:silu/event_bus.dart';
import 'package:silu/global_declare.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/oss.dart';
import 'package:silu/pages/address_selector.dart';
import 'package:silu/utils.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/widgets/bottom_widgets.dart';
import 'package:silu/widgets/img_cropper.dart';

class UploadBlogPage extends StatefulWidget {
  const UploadBlogPage({Key? key}) : super(key: key);

  @override
  _UploadBlogPageState createState() => _UploadBlogPageState();
}

class _UploadBlogPageState extends State<UploadBlogPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  static const _maxImgNum = 9;
  final _imgList = <Uint8List>[];

  var _isBlogLongTime = false;
  var _blogAccessTime = '';
  var _address = '';
  var _latLng = AMap().lastLatLng;
  var _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadTempBlog();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 44,
          backgroundColor: Colors.white,
          foregroundColor: Colors.brown,
          elevation: 0,
        ),
        body: ListView(children: [
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
              textCapitalization: TextCapitalization.words,
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
                textCapitalization: TextCapitalization.words,
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
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => AddressSelector(onTapReturn: (Address addr) {
                  setState(() {
                    _latLng = LatLng(addr.latitude, addr.longtitude);
                    _address = addr.addressName;
                  });
                }),
              ));
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
        ]),
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
                      onPressed: _saveTempBlog,
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
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: const Text('发布动态'),
                    onPressed: _uploadBlog,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('您有未保存的修改，要返回编辑吗？'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('返回编辑')),
          TextButton(
              onPressed: () {
                _saveTempBlog();
                Navigator.of(context).pop(true);
              },
              child: const Text('保存并退出')),
        ],
      ),
    );
    return Future.value(result ?? false);
  }

  _loadTempBlog() {
    final sp = u.sharedPreferences;
    if (sp.getBool('exist_temp_blog') ?? false) {
      var strList = sp.getStringList('temp_blog_imgs') ?? <String>[];
      for (var str in strList) {
        _imgList.add(base64Decode(str));
      }
      _titleController.text = sp.getString('temp_blog_title') ?? '';
      _contextController.text = sp.getString('temp_blog_context') ?? '';
    }
    setState(() {});
  }

  _saveTempBlog() {
    final sp = u.sharedPreferences;
    var strList = <String>[];
    for (var img in _imgList) {
      strList.add(base64Encode(img));
    }
    sp.setBool('exist_temp_blog', true);
    sp.setStringList('temp_blog_imgs', strList);
    sp.setString('temp_blog_title', _titleController.text);
    sp.setString('temp_blog_context', _contextController.text);
    Fluttertoast.showToast(msg: '草稿已保存');
  }

  _imgCard(int index) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showBottomButtons(context, children: [
          TextButton(
            child: const Text('预览图片', style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
              return Image.memory(_imgList[index]);
            })),
          ),
          const Divider(),
          TextButton(
            child: const Text('删除图片', style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() => _imgList.removeAt(index));
              Navigator.of(context).pop();
            },
          ),
        ]),
        child: Image.memory(_imgList[index], fit: BoxFit.cover, width: 100),
      ),
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
          var img = await imgCropper(context);
          if (img != null) {
            setState(() => _imgList.add(img));
          }
        },
        child: const SizedBox(
          width: 100,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  _uploadBlog() async {
    if (_isUploading) {
      Fluttertoast.showToast(msg: '上传中，请稍后');
      return;
    } else if (_titleController.text.isEmpty || _contextController.text.isEmpty || _imgList.isEmpty) {
      Fluttertoast.showToast(msg: '内容不能为空哦');
      return;
    }

    Fluttertoast.showToast(msg: '开始上传，请稍后');
    _isUploading = true;
    final sp = u.sharedPreferences;

    // 图片上传OSS
    final imgInfoList = <Map<String, dynamic>>[];
    for (var elm in _imgList) {
      var result = await Bucket().uploadImg(OssImgCategory.images, elm);
      if (result != null) {
        imgInfoList.add(result);
      } else {
        print('OSS上传失败');
      }
    }

    // 表单上传后端
    var data = {
      'user_id': u.uid,
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
    if (rsp.statusCode == SiluResponse.ok) {
      Fluttertoast.showToast(msg: '上传成功');
      sp.setBool('exist_temp_blog', false);
      bus.emit('user_view_update', u.uid);
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(msg: '上传失败，请检查网络');
    }
    _isUploading = false;
  }
}
