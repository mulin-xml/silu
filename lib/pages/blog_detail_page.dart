// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import 'package:silu/global_declare.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/utils.dart';
import 'package:silu/widgets/bottom_input_field.dart';
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

  bool isLiked = false;
  bool isCollected = false;
  int likeNum = 0;
  int collectNum = 0;
  String _tmpComment = '';

  @override
  void initState() {
    super.initState();
    updateState();
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
      bottomNavigationBar: Material(
        color: Colors.white,
        elevation: 10,
        child: Container(
          height: 60,
          child: _bottomBar(),
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _bottomButton(
        isLiked ? const Icon(Icons.favorite, color: Colors.red) : const Icon(Icons.favorite_border),
        likeNum.toString(),
        () async {
          var data = {
            'user_id': u.uid,
            'activity_id': widget.blog.activityId,
            'mark_type': 1,
            'action': isLiked ? 1 : 0,
          };
          var rsp = await SiluRequest().post('mark_activity', data);
          if (rsp.statusCode == HttpStatus.ok) {
            updateState();
          }
        },
      ),
      const SizedBox(width: 20),
      _bottomButton(
        isCollected ? const Icon(Icons.star, size: 30, color: Colors.yellow) : const Icon(Icons.star_border_rounded, size: 30),
        collectNum.toString(),
        () async {
          var data = {
            'user_id': u.uid,
            'activity_id': widget.blog.activityId,
            'mark_type': 2,
            'action': isCollected ? 1 : 0,
          };
          var rsp = await SiluRequest().post('mark_activity', data);
          if (rsp.statusCode == HttpStatus.ok) {
            updateState();
          }
        },
      ),
      const SizedBox(width: 20),
      _bottomButton(
        const Icon(Icons.mode_comment_outlined),
        '0',
        () => showBottomInputField(
          context,
          onCommit: (String text) {
            _tmpComment = text;
          },
          text: _tmpComment,
        ),
      ),
    ]);
  }

  Widget _bottomButton(Icon icon, String text, void Function() onTap) {
    return GestureDetector(
      child: Row(mainAxisSize: MainAxisSize.min, children: [icon, Text(text)]),
      onTap: onTap,
    );
  }

  _addVisitNum() {
    var data = {
      'user_id': u.uid,
      'activity_id': widget.blog.activityId,
      'mark_type': 0,
    };
    SiluRequest().post('mark_activity', data);
  }

  updateState() async {
    var data = {
      'login_user_id': u.uid,
      'activity_id': widget.blog.activityId,
    };
    var rsp = await SiluRequest().post('get_activity_info', data);
    likeNum = rsp.data['activity_info']['love_count'];
    collectNum = rsp.data['activity_info']['collection_count'];
    isLiked = rsp.data['activity_info']['love_status'];
    isCollected = rsp.data['activity_info']['collection_status'];
    setState(() {});
    _addVisitNum();
  }
}
