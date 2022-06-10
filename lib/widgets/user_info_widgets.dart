// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:silu/image_cache.dart';
import 'package:silu/pages/user_page.dart';
import 'package:silu/user_info_cache.dart';

class UserIcon extends StatelessWidget {
  const UserIcon(this.userId, {Key? key, double? size}) : super(key: key);

  final int userId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserInfo>(
      future: UserInfoCache().cachedUserInfo(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _imgBox(snapshot.data?.iconKey ?? '');
        }
        return _imgBox('');
      },
    );
  }

  Widget _imgBox(String iconKey, {double? size}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 500, maxWidth: 500),
      child: FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.9,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            height: size,
            width: size,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: iconKey.isEmpty ? FlutterLogo(size: size) : Image(image: OssImage(OssImgCategory.icons, iconKey), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class UserTopbar extends StatefulWidget {
  const UserTopbar(this.authorId, {Key? key}) : super(key: key);

  final int authorId;

  @override
  State<UserTopbar> createState() => _UserTopbarState();
}

class _UserTopbarState extends State<UserTopbar> {
  String _authorName = '';

  _getAuthorInfo() async {
    final userInfo = await UserInfoCache().cachedUserInfo(widget.authorId);
    if (mounted) {
      setState(() {
        _authorName = userInfo.userName;
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
          UserIcon(widget.authorId),
          const SizedBox(width: 10),
          Text(_authorName, style: const TextStyle(inherit: false, color: Colors.brown)),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => userPage(widget.authorId))),
    );
  }
}
