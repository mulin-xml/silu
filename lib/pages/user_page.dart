// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:silu/blog.dart';
import 'package:silu/image_cache.dart';
import 'package:silu/pages/edit_user_info_page.dart';
import 'package:silu/widgets/blog_view.dart';
import 'package:silu/event_bus.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

class UserPage extends StatefulWidget {
  const UserPage(this.isSelf, {Key? key}) : super(key: key);

  final bool isSelf;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with AutomaticKeepAliveClientMixin {
  final _blogItems = <Widget>[];
  var _userName = '';
  var _introduction = '';
  var _iconKey = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    updatePage();
    bus.on('user_page_update', (arg) => updatePage());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      child: ListView.separated(
        itemCount: _blogItems.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return UserAccountsDrawerHeader(
              accountName: Text(_userName),
              accountEmail: Text(_introduction != 'None' ? _introduction : '暂无简介'),
              currentAccountPicture: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: _iconKey.isEmpty ? const FlutterLogo() : Image(image: OssImage(OssImgCategory.icons, _iconKey), fit: BoxFit.cover),
              ),
              otherAccountsPictures: widget.isSelf
                  ? [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => EditUserInfoPage(_iconKey, _userName, _introduction)));
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          '编辑资料',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ]
                  : null,
              otherAccountsPicturesSize: const Size(100, 40),
            );
          } else {
            return index - 1 < _blogItems.length ? _blogItems[index - 1] : Container();
          }
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
      onRefresh: () async {
        updatePage();
      },
    );
  }

  _getMyBlogs() async {
    final sp = u.sharedPreferences;
    var data = {
      'offset': 0,
      'limit': 500,
      'login_user_id': sp.getString('user_id'),
      'search_user_id': sp.getString('user_id'),
    };
    var rsp = await SiluRequest().post('get_user_activity_list', data);
    if (rsp.statusCode == HttpStatus.ok) {
      List activityList = rsp.data['activityList'];
      for (var elm in activityList) {
        _blogItems.add(BlogItemView(Blog(elm), widget.isSelf));
      }
    }
    setState(() {});
  }

  updatePage() {
    _blogItems.clear();
    _getUserInfo();
    _getMyBlogs();
  }

  _getUserInfo() async {
    var rsp = await SiluRequest().post('get_user_info', {'user_id': u.sharedPreferences.getString('user_id')});
    if (rsp.statusCode == HttpStatus.ok) {
      print(rsp.data);
      setState(() {
        _userName = rsp.data['userInfo']['username'];
        _introduction = rsp.data['userInfo']['introduction'];
        _iconKey = rsp.data['userInfo']['icon_key'];
      });
    }
  }
}
