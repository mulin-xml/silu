// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:silu/image_cache.dart';

class Blog {
  Blog(this.activityId, this.title, this.content, this.imagesInfo);
  bool isSaved = false;
  final int activityId;
  final String title;
  final String content;
  final List<dynamic> imagesInfo;
  final String authorName = "Author Name";
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          // 图片列表
          AspectRatio(
            child: Swiper(
              itemBuilder: (BuildContext context, int index) => Image(image: OssImage(widget.blog.imagesInfo[index]['key'])),
              loop: false,
              itemCount: widget.blog.imagesInfo.length,
              pagination: widget.blog.imagesInfo.length > 1 ? const SwiperPagination() : null,
            ),
            aspectRatio: 0.75,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: Text(widget.blog.title, textScaleFactor: 1.5),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
            child: Text(widget.blog.content.replaceAll('\\n', '\n'), textScaleFactor: 1.2),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
