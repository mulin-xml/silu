// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:silu/blog.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/pages/blog_view_page.dart';
import 'package:silu/utils.dart';

editUserInfo() async {
  var form = {
    'user_id': Utils().sharedPreferences.getString('user_id'),
    'new_username': '思路官方账号1',
  };
  var rsp = await SiluRequest().post('edit_user_info', form);
  print(rsp.data);
}

getUserInfo() async {
  var rsp = await SiluRequest().post('get_user_info', {'user_id': Utils().sharedPreferences.getString('user_id')});
  print(rsp.data);
}

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserPage> {
  final _blogs = <Blog>[];

  @override
  Widget build(BuildContext context) {
    getMyBlogs();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            height: 400,
            color: Colors.brown,
          ),
          const Divider(),
          ListTile(
            title: const Text('我发布的'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
              return Scaffold(
                backgroundColor: Colors.grey.shade50,
                appBar: AppBar(
                  toolbarHeight: 45,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.brown,
                  elevation: 0,
                ),
                body: MasonryGridView.count(
                    crossAxisCount: 2,
                    itemCount: _blogs.length,
                    addAutomaticKeepAlives: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) => _buildBlogCardForMySelf(_blogs[index])),
              );
            })),
          ),
          const Divider(),
        ],
      ),
    );
  }

  _buildBlogCardForMySelf(Blog blog) {
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
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () async {
                      var rsp = await SiluRequest().post('delete_activity_admin', {'activity_id': blog.activityId});
                      if (rsp.statusCode == HttpStatus.ok && rsp.data['status']) {
                        Fluttertoast.showToast(msg: '删除成功');
                        setState(() {
                          _blogs.remove(blog);
                        });
                      } else {
                        Fluttertoast.showToast(msg: '删除失败');
                      }
                    },
                    icon: const Icon(Icons.delete)),
              ],
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

  getMyBlogs() async {
    final sp = Utils().sharedPreferences;
    var data = {
      'offset': 0,
      'limit': 50,
      'login_user_id': sp.getString('user_id'),
      'search_user_id': sp.getString('user_id'),
    };
    var rsp = await SiluRequest().post('get_user_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok && rsp.data['status']) {
      List activityList = rsp.data['activityList'];
      for (var elm in activityList) {
        _blogs.add(Blog(elm));
      }
    }
  }
}
