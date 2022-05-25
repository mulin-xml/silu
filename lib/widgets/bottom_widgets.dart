// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

Widget bottomInputField(
  BuildContext context, {
  String? text,
  void Function(TextEditingController)? onCommit,
  void Function(String)? onPop,
  bool autoFocus = false,
}) {
  final textController = TextEditingController(text: text);
  return WillPopScope(
    child: Padding(
      // 底部和键盘高度对齐
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: textController,
              textCapitalization: TextCapitalization.words,
              autofocus: autoFocus,
              maxLines: 3,
              minLines: 1,
              maxLength: 500,
              style: const TextStyle(color: Colors.brown),
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: true,
                counterText: '',
              ),
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            child: const Text('发送'),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            onPressed: () => onCommit?.call(textController),
          ),
        ]),
      ),
    ),
    onWillPop: () async {
      onPop?.call(textController.text);
      return Future.value(true);
    },
  );
}

Future<String?> showBottomButtons(context, {List<Widget> children = const <Widget>[]}) {
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Column(children: children),
      );
    },
  );
}