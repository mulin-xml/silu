// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';

import 'package:silu/image_cache.dart';
import 'package:silu/pages/user_page.dart';
import 'package:silu/user_info_cache.dart';

class UserIcon extends StatelessWidget {
  const UserIcon(this.userId, {Key? key, this.size}) : super(key: key);

  final int userId;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserInfo>(
      future: UserInfoCache().cachedUserInfo(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return _imgBox(snapshot.data!.iconKey);
        }
        return _imgBox('');
      },
    );
  }

  Widget _imgBox(String iconKey) {
    return LayoutBuilder(builder: ((context, constraints) {
      final double maxSize = min(min(constraints.maxHeight, constraints.maxWidth), 300);
      return Container(
        height: size ?? maxSize,
        width: size ?? maxSize,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: iconKey.isEmpty ? FlutterLogo(size: size) : Image(image: OssImage(OssImgCategory.icons, iconKey), fit: BoxFit.cover),
      );
    }));
  }
}

class UserIconAndName extends StatelessWidget {
  const UserIconAndName(this.authorId, {Key? key, this.height}) : super(key: key);

  final int authorId;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserIcon(authorId, size: height),
          const SizedBox(width: 10),
          FutureBuilder<UserInfo>(
            future: UserInfoCache().cachedUserInfo(authorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return Text(snapshot.data!.userName, style: const TextStyle(inherit: false, color: Colors.brown));
              }
              return Container();
            },
          )
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => userPage(authorId))),
    );
  }
}
