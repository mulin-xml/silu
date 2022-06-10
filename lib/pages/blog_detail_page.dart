// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:silu/event_bus.dart';

import 'package:silu/global_declare.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/utils.dart';
import 'package:silu/widgets/bottom_widgets.dart';
import 'package:silu/widgets/follow_button.dart';
import 'package:silu/widgets/user_info_widgets.dart';

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
  final _commentList = <Widget>[];

  @override
  void initState() {
    super.initState();
    updateState();
    bus.on('blog_detail_update', (arg) {
      if (arg == widget.blog.activityId) {
        updateState();
      }
    });
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
            aspectRatio: _minAspectRatio,
            child: PageView.builder(
              itemCount: widget.blog.imagesInfo.length,
              itemBuilder: (BuildContext context, int index) => Image(image: OssImage(OssImgCategory.images, widget.blog.imagesInfo[index]['key'])),
            ),
          ),
          const SizedBox(height: 10),
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              widget.blog.title,
              textScaleFactor: 1.4,
              style: const TextStyle(wordSpacing: -3),
            ),
          ),
          const SizedBox(height: 10),
          // 内容
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              widget.blog.content.replaceAll('\\n', '\n'),
              textScaleFactor: 1.2,
              style: const TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 50),
          // 文末信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              '编辑于 ' + widget.blog.createTime,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const Divider(),
          Column(children: _commentList),
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
          if (rsp.statusCode == SiluResponse.ok) {
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
          if (rsp.statusCode == SiluResponse.ok) {
            updateState();
          }
        },
      ),
      const SizedBox(width: 20),
      _bottomButton(
        const Icon(Icons.mode_comment_outlined),
        _commentList.length.toString(),
        () => _showBottomInputField(),
      ),
    ]);
  }

  Future<String?> _showBottomInputField() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return bottomInputField(
          context,
          text: _tmpComment,
          autoFocus: true,
          onPop: (String text) => _tmpComment = text,
          onCommit: (TextEditingController controller) async {
            final data = {
              'user_id': u.uid,
              'activity_id': widget.blog.activityId,
              'father_comment_id': -1,
              'content': controller.text,
            };
            final rsp = await SiluRequest().post('upload_comment', data);
            if (rsp.statusCode == SiluResponse.ok) {
              updateState();
              _tmpComment = '';
              Navigator.of(context).pop();
            } else {
              Fluttertoast.showToast(msg: '上传评论失败');
            }
          },
        );
      },
    );
  }

  Widget _bottomButton(Icon icon, String text, void Function() onTap) {
    return GestureDetector(
      child: Row(mainAxisSize: MainAxisSize.min, children: [icon, Text(text)]),
      onTap: onTap,
    );
  }

  _getActivityInfo() async {
    final data = {
      'login_user_id': u.uid,
      'activity_id': widget.blog.activityId,
    };
    final rsp = await SiluRequest().post('get_activity_info', data);
    likeNum = rsp.data['activity_info']['love_count'];
    collectNum = rsp.data['activity_info']['collection_count'];
    isLiked = rsp.data['activity_info']['love_status'];
    isCollected = rsp.data['activity_info']['collection_status'];
    setState(() {});
  }

  _getComments() async {
    final data = {
      'offset': 0,
      'limit': 500,
      'activity_id': widget.blog.activityId,
    };
    final rsp = await SiluRequest().post('get_comment_by_activity_id', data);
    if (rsp.statusCode == SiluResponse.ok) {
      _commentList.clear();
      for (final elm in rsp.data['comment_list']) {
        _commentList.add(CommentItem(widget.blog.activityId, elm['id'], elm['author_id'], elm['content']));
      }
    }
    setState(() {});
  }

  updateState() {
    _getActivityInfo();
    _getComments();
  }
}

class CommentItem extends StatefulWidget {
  const CommentItem(this.activityId, this.commentId, this.authorId, this.content, {Key? key}) : super(key: key);

  final int activityId;
  final int commentId;
  final int authorId;
  final String content;

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.centerLeft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 20, child: UserTopbar(widget.authorId)),
          Text(widget.content),
        ]),
      ),
      onLongPress: () {
        showBottomButtons(context, children: [
          Visibility(
            visible: true,
            child: TextButton(
              child: const Text('回复此人', style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: () {},
            ),
          ),
          TextButton(
            child: const Text('举报', style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
            onPressed: () {},
          ),
          Visibility(
            visible: u.uid == widget.authorId,
            child: TextButton(
              child: const Text('删除评论', style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: _deleteComment,
            ),
          ),
        ]);
      },
    );
  }

  _deleteComment() async {
    final rsp = await SiluRequest().post('delete_comment', {'comment_id': widget.commentId});
    Fluttertoast.showToast(msg: rsp.statusCode == SiluResponse.ok ? '删除成功' : '删除失败');
    bus.emit('blog_detail_update', widget.activityId);
    Navigator.of(context).pop();
  }
}
