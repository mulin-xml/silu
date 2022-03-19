// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:silu/http_manager.dart';

class Blog {
  Blog(this.activityId, this.title, this.content, this.imagesInfo);

  bool isSaved = false;

  final int activityId;
  final String title;
  final String content;
  final List<dynamic> imagesInfo;
  final String authorName = "Author Name";

  final authorImg = const FlutterLogo();
}

class BlogViewPage extends StatefulWidget {
  const BlogViewPage(this.blog, {Key? key}) : super(key: key);

  final Blog blog;

  @override
  State<BlogViewPage> createState() => _BlogViewPageState();
}

class _BlogViewPageState extends State<BlogViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 图片列表
          const Text('测试界面，请勿删除动态'),
          SizedBox(
            height: 500,
            child: ListView.builder(
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, final int physicIdx) {
                return Container();
              },
            ),
          ),
          Text(widget.blog.title),
          Text(widget.blog.content),
        ],
      ),
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
                    onPressed: () async {
                      var rsp = await SiluRequest().post('delete_activity_admin', {'activity_id': '5'});
                      if (rsp.statusCode == HttpStatus.ok && rsp.data['status']) {
                        Fluttertoast.showToast(msg: '删除成功');
                        Navigator.of(context).pop();
                      } else {
                        Fluttertoast.showToast(msg: '删除失败');
                      }
                    },
                    child: const Icon(Icons.storefront),
                  ),
                  const Text("删除", style: TextStyle(color: Colors.brown)),
                ],
              ),
            ),
            // Expanded(
            //   flex: 7,
            //   child: Container(
            //     padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
            //     child: ElevatedButton(
            //       style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
            //       child: const Text('发布动态'),
            //       onPressed: () {},
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
