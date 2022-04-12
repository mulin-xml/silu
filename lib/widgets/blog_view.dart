import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import 'package:silu/blog.dart';
import 'package:silu/event_bus.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/pages/blog_view_page.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/amap.dart';

class BlogCardView extends StatefulWidget {
  const BlogCardView(this.blog, {Key? key}) : super(key: key);

  final Blog blog;

  @override
  State<BlogCardView> createState() => _BlogCardViewState();
}

class _BlogCardViewState extends State<BlogCardView> {
  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;
    double distance;
    if (blog.latitude < 0 || blog.longtitude < 0) {
      distance = -1;
    } else {
      distance = AMapTools.distanceBetween(LatLng(blog.latitude, blog.longtitude), AMap().lastLatLng).round() / 1000;
    }

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
                    children: [
                      const Icon(Icons.location_on_outlined),
                      Text(distance.toString() + 'km'),
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
}

class BlogItemView extends StatefulWidget {
  const BlogItemView(this.blog, {Key? key}) : super(key: key);

  final Blog blog;

  @override
  State<BlogItemView> createState() => _BlogItemViewState();
}

class _BlogItemViewState extends State<BlogItemView> {
  final imgs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 80, child: Icon(Icons.account_circle_outlined, size: 50)),
        Expanded(
          child: Column(
            children: [
              // Text(
              //   widget.blog.title + widget.blog.content,
              //   maxLines: 5,
              // ),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: widget.blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: '  '),
                  TextSpan(text: widget.blog.content),
                ]),
                maxLines: 5,
              ),
              _nineGrid(),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      var rsp = await SiluRequest().post('delete_activity_admin', {'activity_id': widget.blog.activityId});
                      if (rsp.statusCode == HttpStatus.ok && rsp.data['status']) {
                        Fluttertoast.showToast(msg: '删除成功');
                        bus.emit('user_page_update');
                      } else {
                        Fluttertoast.showToast(msg: '删除失败');
                      }
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  _nineGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, //每行三列
        childAspectRatio: 1.0, //显示区域宽高相等
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Image(image: OssImage(widget.blog.imagesInfo[index]['key']), fit: BoxFit.cover);
      },
      itemCount: widget.blog.imagesInfo.length,
    );
  }
}
