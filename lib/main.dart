// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'edit_blog_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 顶部状态栏透明
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      title: '思路', // 在任务管理器中显示的标题
      home: const SplashPage(),
      theme: ThemeData(primarySwatch: Colors.brown),
      color: Colors.brown,
    );
  }
}

class Blog {
  Blog()
      : title = "魔都探店-海底捞惊喜狂欢折扣" * (Random().nextInt(2) + 1),
        mainImg = FadeInImage.assetNetwork(placeholder: 'images/0.jpg', image: 'http://0--0.top/apis/image/' + (Random().nextInt(16) + 1).toString());
  // mainImg = Image.network('http://0--0.top/apis/image/' + (Random().nextInt(16) + 1).toString()),

  final String title;
  bool isSaved = false;
  String authorName = "Author Name";
  final FadeInImage mainImg;
  var authorImg = const FlutterLogo();
}

Iterable<Blog> generateBlogs() sync* {
  while (true) {
    yield Blog();
  }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const EditBlogPage())),
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.grey.shade200,
    );
  }

  _lineListView(final int offset, ScrollController sc) {
    // 放在这里的局部变量只会在ListView初始化的时候定值，此后不会改变
    return ListView.builder(
      controller: sc,
      // itemCount: _blogs.length + 1,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, final int physicIdx) {
        // 放在这里的局部变量会在ListView中某一项刷新到的时候定值，实时变化
        final int blogIdx = physicIdx * 2 + offset;
        if (blogIdx >= _blogs.length) {
          _blogs.addAll(generateBlogs().take(5));
          print(blogIdx);
        }
        return _buildBlogCard(_blogs[blogIdx]);
      },
    );
  }

  _buildBlogCard(Blog blog) {
    return Card(
      clipBehavior: Clip.antiAlias,
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
      'limit': 1000,
    });
    try {
      var response = await Dio().post(url, data: formData);
      result = response.toString();
    } catch (e) {
      result = '[Error Catch]' + e.toString();
    }
    List activityList = json.decode(result)['activityList'];
    print(activityList);
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const MyHomePage()));
    });
    return Container(
      child: const FlutterLogo(),
      color: Colors.white,
    );
  }
}
