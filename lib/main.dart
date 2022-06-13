// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:silu/pages/force_update_page.dart';
import 'package:silu/pages/upload_blog_page.dart';
import 'package:silu/pages/homepage_discover.dart';
import 'package:silu/pages/homepage_message.dart';
import 'package:silu/pages/user_page.dart';
import 'package:silu/pages/login_page.dart';
import 'package:silu/pages/homepage_follow.dart';
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
      routes: {
        '/login_page': (BuildContext context) => const LoginPage(),
      },
      theme: ThemeData(primarySwatch: Colors.brown),
      color: Colors.brown,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: const Locale('zh', 'CN'),
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
  final pages = [
    const DiscoverPage(),
    const FollowPage(),
    const MessagePage(),
    const SelfPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        itemBuilder: (context, index) => pages[index],
        onPageChanged: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UploadBlogPage())),
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
        onTap: (index) => _pageController.jumpToPage(index),
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () async {
      if (await VersionCheck().isUpdateNecessary) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const ForceUpdatePage()));
      } else if (u.isLogin) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const MyHomePage()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const LoginPage()));
      }
    });
    return Container(
      child: Image.asset(
        'images/silu_logo.png',
        height: 150,
        fit: BoxFit.cover,
        width: 400,
        color: Colors.brown,
      ),
      alignment: Alignment.bottomCenter,
      color: Colors.white,
    );
  }
}
