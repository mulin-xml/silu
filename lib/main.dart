// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:silu/pages/user_info_page.dart';
import 'package:silu/pages/edit_blog_page.dart';
import 'package:silu/pages/user_login_page.dart';
import 'package:silu/pages/blog_view_page.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/utils.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _blogs = <Blog>[];
  var _isGetting = false;
  var _offset = 0;

  @override
  void initState() {
    super.initState();
    getBatchBlogs();
  }

  @override
  void dispose() {
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
          IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserLoginPage()));
              }),
          IconButton(
              icon: const Icon(Icons.face),
              onPressed: () {
                final sp = Utils().sharedPreferences;
                if (sp.getBool('is_login') ?? false) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserInfoPage()));
                } else {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserLoginPage()));
                }
              }),
        ],
      ),
      body: MasonryGridView.count(
          crossAxisCount: 2,
          itemCount: _blogs.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _buildBlogCard(_blogs[index]);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final sp = Utils().sharedPreferences;
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

  _buildBlogCard(Blog blog) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            child: FadeInImage(
              image: OssImage(blog.ossImgKey[0]['key']),
              placeholder: const AssetImage('images/0.jpg'),
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => BlogViewPage(blog))),
          ),
          ListTile(
            title: Text(blog.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // blog.authorImg,
                // Text(
                //   blog.authorName,
                //   textScaleFactor: 0.7,
                // ),
                const Icon(Icons.location_on_outlined),
                const Text('0.0km'),
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
        _blogs.add(Blog(elm['id'], elm['title'], elm['content'], elm['images_info']));
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
