// ignore_for_file: avoid_print

import 'dart:convert';
// import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 顶部状态栏透明
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return MaterialApp(
      title: '思路',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(),
    );
  }
}

class Blog {
  Blog() {
    int rd = Random().nextInt(3) + 1;
    title = "魔都探店-海底捞惊喜狂欢折扣" * rd;

    mainImg = Image.network(
      'http://0--0.top/apis/image',
      headers: {'image_id': rd.toString()},
      // errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
      //   print(exception.toString());
      //   return const FlutterLogo(
      //     size: 500,
      //   );
      // },
      // loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      //   return child;
      // },
    );
  }
  String title = "";
  bool isSaved = false;
  String authorName = "Author Name";
  Image? mainImg;
  var authorImg = const FlutterLogo();
}

Iterable<Blog> generateBlogs() sync* {
  while (true) {
    yield Blog();
  }
}

uploadBlog() async {
  const url = 'http://0--0.top/apis/upload_activity';
  var result = "";

  final picker = ImagePicker();
  var image = await picker.pickImage(source: ImageSource.gallery);

  var path = "";
  if (image != null) {
    path = image.path;
  }
  Fluttertoast.showToast(msg: path);
  var name = path.substring(path.lastIndexOf("/") + 1, path.length);

  var formData = FormData.fromMap({
    'authorName': 'admin',
    'mainImg': await MultipartFile.fromFile(path, filename: name),
  });

  try {
    var response = await Dio().post(url, data: formData);
    result = response.toString();
  } catch (e) {
    result = '[Error Catch]' + e.toString();
  }
  Fluttertoast.showToast(msg: result);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _blogs = <Blog>[];
  final _controllers = LinkedScrollControllerGroup();
  late ScrollController _sc1;
  late ScrollController _sc2;

  @override
  void initState() {
    super.initState();
    _sc1 = _controllers.addAndGet();
    _sc2 = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _sc1.dispose();
    _sc2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.list), onPressed: downloadBlog),
        ],
      ),
      body: Row(
        children: [
          Expanded(child: _lineListView(0, _sc1)),
          Expanded(child: _lineListView(1, _sc2)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _editBlogPage,
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 2,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildBottomItem(0, Icons.home, "首页")),
            Expanded(child: _buildBottomItem(1, Icons.library_music, "发现")),
            Expanded(child: _buildBottomItem(-1, null, "")),
            Expanded(child: _buildBottomItem(2, Icons.email, "消息")),
            Expanded(child: _buildBottomItem(3, Icons.person, "我的")),
          ],
        ),
      ),
    );
  }

  _buildBottomItem(int index, IconData? iconData, String title) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        height: 90,
        child: Container(
          color: index == 1 ? Colors.red : Colors.blue,
          child: Column(
            children: [Icon(iconData), Text(title)],
          ),
        ),
      ),
    );
  }

  _lineListView(final int offset, ScrollController sc) {
    // 放在这里的局部变量只会在ListView初始化的时候定值，此后不会改变
    return ListView.builder(
        controller: sc,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, final int physicIdx) {
          // 放在这里的局部变量会在ListView中某一项刷新到的时候定值，实时变化
          final int blogIdx = physicIdx * 2 + offset;

          if (blogIdx >= _blogs.length) {
            _blogs.addAll(generateBlogs().take(10));
          }

          return _buildBlogCard(_blogs[blogIdx]);
        });
  }

  _buildBlogCard(Blog blog) {
    return Card(
      child: Column(
        children: [
          Container(
            child: blog.mainImg,
            color: Colors.blue,
          ),
          ListTile(
            title: Text(blog.title),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                blog.authorImg,
                Text(
                  blog.authorName,
                  textScaleFactor: 0.7,
                ),
                Icon(
                  blog.isSaved ? Icons.favorite : Icons.favorite_border,
                  color: blog.isSaved ? Colors.red : null,
                ),
              ],
            ),
            onTap: () {
              // 如果不使用setState的话，红心状态不会立刻刷新
              setState(() => blog.isSaved = !blog.isSaved);
            },
          ),
        ],
      ),
    );
  }

  _editBlogPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 45,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: Container(
              child: null,
            ),
            floatingActionButton: const FloatingActionButton(
              onPressed: uploadBlog,
              child: Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  downloadBlog() async {
    const url = 'http://0--0.top/apis/get_activity_list';
    var result = "";

    var formData = FormData.fromMap({
      'offset': 0,
      'limit': 5,
    });

    try {
      var response = await Dio().post(url, data: formData);
      result = response.toString();
    } catch (e) {
      result = '[Error Catch]' + e.toString();
    }

    List activityList = json.decode(result)['activityList'];

    print(activityList[0]['images_ids'][0]);
  }
}
