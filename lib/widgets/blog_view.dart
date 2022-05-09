// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import 'package:silu/global_declare.dart';
import 'package:silu/event_bus.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/pages/blog_detail_page.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/amap.dart';
import 'package:silu/widgets/user_topbar.dart';

class _BlogCard extends StatelessWidget {
  const _BlogCard(this.blog, {Key? key}) : super(key: key);

  final Blog blog;

  @override
  Widget build(BuildContext context) {
    double distance;
    if (blog.latitude < 0 || blog.longtitude < 0) {
      distance = -1;
    } else {
      distance = AMapTools.distanceBetween(LatLng(blog.latitude, blog.longtitude), amap.lastLatLng).round() / 1000;
    }

    return GestureDetector(
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // 图片
            AspectRatio(
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  // 图片本体
                  Image(image: OssImage(OssImgCategory.images, blog.imagesInfo[0]['key'])),
                  // 图片下方嵌入式信息栏
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    height: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 距离
                        Visibility(
                          visible: !(blog.latitude.isNegative || blog.longtitude.isNegative),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 20, color: Colors.white),
                              Text(
                                distance.toStringAsFixed(2) + 'km',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // 浏览量
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye, size: 20, color: Colors.white),
                            Text(
                              blog.visitCount.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              aspectRatio: blog.imagesInfo[0]['width'] / blog.imagesInfo[0]['height'],
            ),
            const SizedBox(height: 5),
            // 标题
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                blog.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, height: 1.4),
              ),
            ),
            const SizedBox(height: 5),
            // 副标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 20, child: UserTopbar(blog.authorId)),
                  GestureDetector(
                    child: Icon(Icons.adaptive.more),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => BlogDetailPage(blog))),
    );
  }
}

class _BlogItem extends StatelessWidget {
  const _BlogItem(this.blog, this.isSelf, {Key? key}) : super(key: key);

  final Blog blog;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 10);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            height: 50,
            alignment: Alignment.centerLeft,
            child: UserTopbar(blog.authorId),
          ),
          sizedBoxSpace,
          Container(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: '  '),
                TextSpan(text: blog.content.replaceAll('\\n', '\n')),
              ]),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            alignment: Alignment.centerLeft,
          ),
          sizedBoxSpace,
          GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: sqrt(blog.imagesInfo.length).ceil(),
              childAspectRatio: 1.0,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Image(image: OssImage(OssImgCategory.images, blog.imagesInfo[index]['key']), fit: BoxFit.cover);
            },
            itemCount: blog.imagesInfo.length,
          ),
          sizedBoxSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '编辑于 ' + blog.createTime,
                style: const TextStyle(color: Colors.grey),
              ),
              Visibility(
                visible: isSelf,
                child: IconButton(
                  onPressed: () async {
                    var rsp = await SiluRequest().post('delete_activity_admin', {'activity_id': blog.activityId});
                    if (rsp.statusCode == HttpStatus.ok) {
                      Fluttertoast.showToast(msg: '删除成功');
                      bus.emit('self_page_update');
                    } else {
                      Fluttertoast.showToast(msg: '删除失败');
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget separatedListView(List<Blog> list, bool isSelf) {
  if (list.isEmpty) {
    return Container(
      alignment: Alignment.center,
      child: const Text('暂无内容', textScaleFactor: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 50),
    );
  }
  return ListView.separated(
    itemCount: list.length,
    itemBuilder: (context, index) {
      return index < list.length ? _BlogItem(list[index], isSelf) : Container();
    },
    separatorBuilder: (context, index) => const Divider(),
  );
}

Widget waterfallListView(List<Blog> list) {
  if (list.isEmpty) {
    return Container(
      alignment: Alignment.center,
      child: const Text('暂无内容', textScaleFactor: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 50),
    );
  }
  return MasonryGridView.count(
    padding: EdgeInsets.zero,
    crossAxisCount: 2,
    itemCount: list.length,
    addAutomaticKeepAlives: true,
    physics: const BouncingScrollPhysics(),
    itemBuilder: (BuildContext context, int index) {
      return index < list.length ? _BlogCard(list[index]) : Container();
    },
  );
}
