import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:silu/amap.dart';
import 'package:silu/blog.dart';
import 'package:silu/pages/blog_view_page.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/utils.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with AutomaticKeepAliveClientMixin {
  final _blogs = <Blog>[];
  var _isGetting = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    updatePage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MasonryGridView.count(
        crossAxisCount: 2,
        itemCount: _blogs.length,
        addAutomaticKeepAlives: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return _buildBlogCard(_blogs[index]);
        });
  }

  _buildBlogCard(Blog blog) {
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
                      Text(calcDistance(blog.latitude, blog.longtitude, AMap().location['latitude'], AMap().location['longitude']).toString() + 'km'),
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

  _getBatchBlogs() async {
    if (_isGetting) {
      return;
    }
    _isGetting = true;
    final sp = Utils().sharedPreferences;
    var data = {
      'offset': 0,
      'limit': 100,
      'login_user_id': (sp.getBool('is_login') ?? false) ? sp.getString('user_id') : '-1',
    };
    var rsp = await SiluRequest().post('get_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok && rsp.data['status']) {
      List activityList = rsp.data['activityList'];
      for (Map<String, dynamic> elm in activityList) {
        _blogs.add(Blog(elm));
      }
    }

    setState(() {});
    _isGetting = false;
  }

  updatePage() {
    _blogs.clear();
    _getBatchBlogs();
  }
}
