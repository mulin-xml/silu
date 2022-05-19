import 'package:flutter/material.dart';
import 'package:silu/widgets/bottom_input_field.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this.friendUserId, {Key? key}) : super(key: key);

  final String friendUserId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(color: Colors.red),
      bottomNavigationBar: bottomInputField(
        context,
        onCommit: (TextEditingController controller) {
          controller.clear();
        },
      ),
    );
  }
}
