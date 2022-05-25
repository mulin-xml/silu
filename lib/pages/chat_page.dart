import 'package:flutter/material.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';
import 'package:silu/widgets/bottom_widgets.dart';

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
        onCommit: (TextEditingController controller) async {
          final data = {
            'from_user_id': u.uid,
            'to_user_id': widget.friendUserId,
            'content': controller.text,
          };
          final rsp = await SiluRequest().post('send_message', data);
          if (rsp.statusCode == SiluResponse.ok) {
            controller.clear();
          }
        },
      ),
    );
  }
}
