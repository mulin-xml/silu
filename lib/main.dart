// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CH'),
        Locale('en', 'US'),
      ],
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          // AppBar
          Container(
            height: 45,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.search, color: Colors.brown),
                    onPressed: () {
                      // Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserLoginPage()));
                    }),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('发现', style: TextStyle(fontWeight: FontWeight.bold))),
                    TextButton(
                      child: const Text('关注', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        final sp = Utils().sharedPreferences;
                        if (sp.getBool('is_login') ?? false) {
                          // Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserInfoPage()));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserLoginPage()));
                        }
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.face, color: Colors.brown),
                  onPressed: () {
                    final sp = Utils().sharedPreferences;
                    if (sp.getBool('is_login') ?? false) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserInfoPage()));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UserLoginPage()));
                    }
                  },
                ),
              ],
            ),
          ),
          // MasonryGridView
          Expanded(
            child: MasonryGridView.count(
                crossAxisCount: 2,
                itemCount: _blogs.length,
                addAutomaticKeepAlives: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return _buildBlogCard(_blogs[index]);
                }),
          )
        ],
      ),
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
    );
  }

  _buildBlogCard(Blog blog) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            child: AspectRatio(
              child: Image(image: OssImage(blog.imagesInfo[0]['key'])),
              aspectRatio: blog.imagesInfo[0]['width'] / blog.imagesInfo[0]['height'],
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => BlogViewPage(blog))),
          ),
          ListTile(
            title: Text(blog.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.location_on_outlined),
                      Text('0.0km'),
                    ],
                  ),
                  Icon(
                    blog.isSaved ? Icons.favorite : Icons.favorite_border,
                    color: blog.isSaved ? Colors.red : null,
                  ),
                ],
              ),
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
    if (rsp.statusCode == HttpStatus.ok && rsp.data['status']) {
      List activityList = rsp.data['activityList'];
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
