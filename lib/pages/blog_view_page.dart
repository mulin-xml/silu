// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import 'package:silu/blog.dart';
import 'package:silu/image_cache.dart';

class BlogViewPage extends StatefulWidget {
  const BlogViewPage(this.blog, {Key? key}) : super(key: key);

  final Blog blog;

  @override
  State<BlogViewPage> createState() => _BlogViewPageState();
}

class _BlogViewPageState extends State<BlogViewPage> {
  @override
  Widget build(BuildContext context) {
    double minAspectRatio = double.maxFinite;
    for (var img in widget.blog.imagesInfo) {
      minAspectRatio = min(minAspectRatio, img['width'] / img['height']);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
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
            aspectRatio: minAspectRatio,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Text(
              widget.blog.title,
              textScaleFactor: 1.4,
              style: const TextStyle(wordSpacing: -3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
            child: Text(
              widget.blog.content.replaceAll('\\n', '\n'),
              textScaleFactor: 1.2,
              style: const TextStyle(height: 1.5),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
