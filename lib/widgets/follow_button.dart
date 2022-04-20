import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  const FollowButton({Key? key}) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  var _title = '关注';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(_title),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          elevation: MaterialStateProperty.all(0),
        ),
      ),
    );
  }
}
