// import 'dart:io';
// import 'dart:convert';
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
    final rd = Random().nextInt(2) + 1;
    title = "魔都探店-海底捞惊喜狂欢折扣" * rd;
  }
  String title = "";
  bool isSaved = false;
  String authorName = "Author Name";
  var mainImg = const FlutterLogo(size: 300);
  var authorImg = const FlutterLogo();
}

Iterable<Blog> generateBlogs() sync* {
  while (true) {
    yield Blog();
  }
}

void httpClientPost() async {
  const url = 'http://0--0.top/apis/postmessage';
  var result = "";
  final picker = ImagePicker();
  var image = await picker.pickImage(source: ImageSource.gallery);

  var dio = Dio();

  Map<String, dynamic> m = {
    'authorName': 'admin',
    'mainImg': image,
  };
  var formData = FormData.fromMap(m);

  try {
    var response = await dio.post(url, data: formData);
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
        elevation: 0,
        actions: const [
          IconButton(icon: Icon(Icons.list), onPressed: null),
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            Expanded(child:
            IconButton(
              icon: const Text('首页'),
              color: Colors.teal,
              onPressed: () {},
            )),
            Expanded(child: 
            IconButton(
              icon: const Text('我的'),
              color: Colors.teal,
              onPressed: () {},
            ),
            ),
            Expanded(child: 
            IconButton(
              icon: const Text('我的'),
              color: Colors.teal,
              onPressed: () {},
            ),
            )
            
            IconButton(
              icon: const Text('首页'),
              color: Colors.teal,
              onPressed: () {},
            ),
            IconButton(
              icon: const Text('我的'),
              color: Colors.teal,
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  Widget _lineListView(final int offset, ScrollController sc) {
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

  Widget _buildBlogCard(Blog blog) {
    return Card(
      child: Column(
        children: [
          Container(
            child: blog.mainImg,
            color: Colors.teal,
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

  void _editBlogPage() {
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
            body: Column(
              children: [
                Expanded(child: Container(color: Colors.brown)),
                Expanded(child: Container(color: Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}
