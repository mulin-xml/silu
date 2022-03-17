// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_blog_page.dart';
import 'user_login_page.dart';
import 'http_manager.dart';
import 'image_cache.dart';
import 'utils.dart';

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
  Blog(this.title, this.ossImgKey);

  bool isSaved = false;

  final String title;
  final String ossImgKey;
  final String authorName = "Author Name";

  final authorImg = const FlutterLogo();
}

// Iterable<Blog> generateBlogs() sync* {
//   while (true) {
//     yield Blog();
//   }
// }

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
  var _isGetting = false;
  var _offset = 0;

  @override
  void initState() {
    super.initState();
    _sc1 = _controllers.addAndGet();
    _sc2 = _controllers.addAndGet();

    getBatchBlogs();
  }

  @override
  void dispose() {
    _sc1.dispose();
    _sc2.dispose();
    super.dispose();
  }

  getUserInfo() async {
    var rsp = await SiluRequest().post('get_user_info', {'user_id': '5'});
    print(rsp.data);
  }

  editUserInfo() async {
    var form = {
      'user_id': '5',
      'new_username': '思路官方账号1',
    };
    var rsp = await SiluRequest().post('edit_user_info', form);
    print(rsp.data);
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
          IconButton(
              icon: const Icon(Icons.face),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserLoginPage()));
              }),
        ],
      ),
      body: Row(
        children: [
          Expanded(child: _lineListView(0, _sc1)),
          Expanded(child: _lineListView(1, _sc2)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final sp = await SharedPreferences.getInstance();
          if (sp.getBool('is_login') ?? false) {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const EditBlogPage()));
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserLoginPage()));
          }
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
      itemCount: _blogs.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, final int physicIdx) {
        // 放在这里的局部变量会在ListView中某一项刷新到的时候定值，实时变化
        // final int blogIdx = physicIdx * 2 + offset;
        // if (blogIdx >= _blogs.length) {
        //   getBatchBlogs();
        //   return const Divider();
        // }
        return _buildBlogCard(_blogs[physicIdx]);
      },
    );
  }

  _buildBlogCard(Blog blog) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          FadeInImage(
            image: OssImage(blog.ossImgKey),
            placeholder: const AssetImage('images/0.jpg'),
          ),
          ListTile(
            title: Text(blog.title, maxLines: 2, overflow: TextOverflow.ellipsis),
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

  getBatchBlogs() async {
    if (_isGetting) {
      return;
    }
    _isGetting = true;
    var rsp = await SiluRequest().post('get_activity_list', {'offset': _offset, 'limit': 50});
    if (rsp.statusCode == HttpStatus.ok) {
      List activityList = jsonDecode(rsp.data)['activityList'];
      for (var elm in activityList) {
        _blogs.add(Blog(elm['title'], elm['images_keys'][0]));
      }
    }
    _offset += 50;
    setState(() {});
    _isGetting = false;
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Utils();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const MyHomePage()));
    });
    return Container(
      child: const FlutterLogo(),
      color: Colors.white,
    );
  }
}
