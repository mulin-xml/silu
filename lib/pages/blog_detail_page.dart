// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import 'package:silu/blog.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/widgets/follow_button.dart';
import 'package:silu/widgets/user_topbar.dart';

class BlogDetailPage extends StatefulWidget {
  const BlogDetailPage(this.blog, {Key? key}) : super(key: key);

  final Blog blog;

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  double _minAspectRatio = double.maxFinite;

  @override
  void initState() {
    super.initState();
    for (var img in widget.blog.imagesInfo) {
      _minAspectRatio = min(_minAspectRatio, img['width'] / img['height']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 40, //返回键宽度稍微收窄一些
        titleSpacing: 0,
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
        title: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UserTopbar(widget.blog.authorId),
              FollowButton(widget.blog.authorId),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          // 图片列表
          AspectRatio(
            child: Swiper(
              itemBuilder: (BuildContext context, int index) => Image(image: OssImage(OssImgCategory.images, widget.blog.imagesInfo[index]['key'])),
              loop: false,
              itemCount: widget.blog.imagesInfo.length,
              pagination: widget.blog.imagesInfo.length > 1 ? const SwiperPagination() : null,
            ),
            aspectRatio: _minAspectRatio,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              widget.blog.title,
              textScaleFactor: 1.4,
              style: const TextStyle(wordSpacing: -3),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              widget.blog.content.replaceAll('\\n', '\n'),
              textScaleFactor: 1.2,
              style: const TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              '编辑于 ' + widget.blog.createTime,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
