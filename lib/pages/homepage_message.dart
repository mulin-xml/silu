// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';
import 'package:silu/widgets/appbar_view.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AutomaticKeepAliveClientMixin {
  Timer? _timer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) => _getMessages());
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: appBarView('消息'),
      body: RefreshIndicator(
        child: ListView(),
        onRefresh: () async {
          _getMessages();
        },
      ),
    );
  }

  _getMessages() async {
    final rsp = await SiluRequest().post('get_new_message_list', {'login_user_id': u.uid});
    if (rsp.statusCode == SiluResponse.ok) {
      print(rsp.data['new_message_list']);
    }
    setState(() {});
  }
}
