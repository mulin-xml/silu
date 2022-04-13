// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';

import 'package:silu/pages/edit_blog_page.dart';
import 'package:silu/pages/homepage_discover.dart';
import 'package:silu/pages/user_page.dart';
import 'package:silu/pages/login_page.dart';
import 'package:silu/utils.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Utils();
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
  int _currentIndex = 0;
  final _pageController = PageController();
  final sp = u.sharedPreferences;
  final pages = [
    const DiscoverPage(),
    const Text('Favourite Page.'),
    const Text('Message Page.'),
    const UserPage(true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.white, elevation: 0),
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        title: const Text('思路'),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return pages[index];
        },
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (sp.getBool('is_login') ?? false) {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const EditBlogPage()));
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const LoginPage()));
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '发现'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_file_outlined), label: '关注'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: '消息'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '我'),
        ],
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 0 || (sp.getBool('is_login') ?? false)) {
            _pageController.jumpToPage(index);
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const LoginPage()));
          }
        },
      ),
      drawer: SizedBox(
        width: 250,
        child: Drawer(
          shape: DrawerTheme.of(context).shape,
          child: ListView(
            children: (sp.getBool('is_login') ?? false)
                ? [
                    const UserAccountsDrawerHeader(
                      accountName: Text('3'),
                      accountEmail: Text('4'),
                      currentAccountPicture: CircleAvatar(child: FlutterLogo(size: 42.0)),
                    ),
                    ListTile(
                      title: const Text('发布动态'),
                      leading: const Icon(Icons.favorite),
                      onTap: () async {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const EditBlogPage()));
                      },
                    ),
                    ListTile(
                      title: const Text('我发布的'),
                      leading: const Icon(Icons.favorite),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('清除缓存'),
                      leading: const Icon(Icons.cached),
                      onTap: () async {
                        Directory tempDir = await getTemporaryDirectory();
                        final List<FileSystemEntity> children = tempDir.listSync();
                        for (final FileSystemEntity child in children) {
                          print(child.path);
                          await child.delete();
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ]
                : [
                    const UserAccountsDrawerHeader(
                      accountName: Text('3'),
                      accountEmail: Text('4'),
                      currentAccountPicture: CircleAvatar(child: FlutterLogo(size: 42.0)),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const MyHomePage()));
    });
    return Container(
      child: const FlutterLogo(),
      color: Colors.white,
    );
  }
}
