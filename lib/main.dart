// ignore_for_file: avoid_print

import 'dart:convert';

// import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:dio/dio.dart';

import 'package:flutter/services.dart';
import 'edit_blog_page.dart';
// import 'package:cached_network_image/cached_network_image.dart';

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
      home: const MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      // color: Colors.white,
    );
  }
}

class Blog {
  Blog() {
    int rd = Random().nextInt(6) + 1;
    title = "魔都探店-海底捞惊喜狂欢折扣" * rd;

    mainImg = Image.network(
      'http://0--0.top/apis/image/' + rd.toString(),
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

grid3x3() {
  return Expanded(
    child: GridView.count(
      children: List<Widget>.filled(9, Container(color: Colors.brown)),
      crossAxisCount: 3,
      padding: const EdgeInsets.all(50),
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 1, // 宽高比例
    ),
  );
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
        foregroundColor: Colors.brown,
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (BuildContext context) {
              return const EditBlogPage();
            }),
          );
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.grey.shade200,
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
            _blogs.addAll(generateBlogs().take(20));
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

  downloadBlog() async {
    const url = 'http://0--0.top/apis/get_activity_list';
    var result = "";
    var formData = FormData.fromMap({
      'offset': 0,
      'limit': 10000,
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
