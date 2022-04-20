import 'package:flutter/material.dart';

import 'package:silu/image_cache.dart';
import 'package:silu/widgets/user_view.dart';
import 'package:silu/utils.dart';

Widget iconView(String iconKey) {
  return Container(
    clipBehavior: Clip.antiAlias,
    decoration: const BoxDecoration(shape: BoxShape.circle),
    child: iconKey.isEmpty ? const FlutterLogo() : Image(image: OssImage(OssImgCategory.icons, iconKey), fit: BoxFit.cover),
  );
}

class UserTopbar extends StatefulWidget {
  const UserTopbar(this.authorId, {Key? key}) : super(key: key);

  final String authorId;

  @override
  State<UserTopbar> createState() => _UserTopbarState();
}

class _UserTopbarState extends State<UserTopbar> {
  String _authorName = '';
  String _authorIconKey = '';

  _getAuthorInfo() async {
    var userInfo = await getUserInfo(widget.authorId);
    if (mounted) {
      setState(() {
        _authorName = userInfo?['username'] ?? '';
        _authorIconKey = userInfo?['icon_key'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getAuthorInfo();
  }

  @override
  void didUpdateWidget(covariant UserTopbar oldWidget) {
    super.didUpdateWidget(oldWidget);
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
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(body: UserView(widget.authorId));
      })),
    );
  }
}
