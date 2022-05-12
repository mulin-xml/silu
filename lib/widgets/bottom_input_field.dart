import 'package:flutter/material.dart';

void showBottomInputField(BuildContext context, {void Function(String)? onCommit, String? text}) {
  final textController = TextEditingController(text: text);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Padding(
        // 底部和键盘高度对齐
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          // height: 100,
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: textController,
                textCapitalization: TextCapitalization.words,
                autofocus: true,
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
              onPressed: () {
                if (onCommit != null) {
                  onCommit(textController.text);
                }
              },
            ),
          ]),
        ),
      );
    },
  );
}
