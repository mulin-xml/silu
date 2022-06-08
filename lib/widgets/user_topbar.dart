// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:silu/image_cache.dart';
import 'package:silu/pages/user_page.dart';
import 'package:silu/user_info_cache.dart';

Widget iconView(String iconKey, {double? size}) {
  return Container(
    height: size,
    width: size,
    clipBehavior: Clip.antiAlias,
    decoration: const BoxDecoration(shape: BoxShape.circle),
    child: iconKey.isEmpty ? const FlutterLogo() : Image(image: OssImage(OssImgCategory.icons, iconKey), fit: BoxFit.cover),
  );
}

class UserTopbar extends StatefulWidget {
  const UserTopbar(this.authorId, {Key? key}) : super(key: key);

  final int authorId;

  @override
  State<UserTopbar> createState() => _UserTopbarState();
}

class _UserTopbarState extends State<UserTopbar> {
  String _authorName = '';
  String _authorIconKey = '';

  _getAuthorInfo() async {
    final userInfo = await UserInfoCache().cachedUserInfo(widget.authorId);
    if (mounted) {
      setState(() {
        _authorName = userInfo.userName;
        _authorIconKey = userInfo.iconKey;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getAuthorInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconView(_authorIconKey),
          const SizedBox(width: 10),
          Text(_authorName, style: const TextStyle(inherit: false, color: Colors.brown)),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => userPage(widget.authorId))),
    );
  }
}
