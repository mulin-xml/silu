// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:silu/utils.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/widgets/appbar_view.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AutomaticKeepAliveClientMixin {
  Timer? _timer;
  final List<String> _msgFiles = u.sharedPreferences.getStringList('msg_files') ?? <String>[];
  final List<Widget> _chatUserWidgets = <Widget>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 启动定时任务
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) => _getMessages());
    // 加载历史记录
    _loadMessages();
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
        child: ListView(
          children: _chatUserWidgets,
        ),
        onRefresh: () async {
          _getMessages();
        },
      ),
    );
  }

  // 定时任务
  _getMessages() async {
    print(_chatUserWidgets.length);
    final rsp = await SiluRequest().post('get_new_message_list', {'login_user_id': u.uid});
    if (rsp.statusCode == SiluResponse.ok) {
      for (final elm in rsp.data['new_message_list']) {
        _procMsgFile(elm['create_time'], elm['from_user_id'], elm['content']);
        _buildMsg(elm['create_time'], elm['from_user_id'], elm['content']);
      }
    }
  }

  _procMsgFile(String time, int userId, String content) async {
    final filename = 'msg-$userId';
    if (!_msgFiles.contains(filename)) {
      _msgFiles.add(filename);
      u.sharedPreferences.setStringList('msg_files', _msgFiles);
    }
    final file = File('${u.cachePath}/$filename');
    if (!file.existsSync()) {
      file.createSync();
    }
    final data = {'time': time, 'content': content};
    file.writeAsStringSync('${jsonEncode(data)}\n', mode: FileMode.writeOnlyAppend);
  }

  _buildMsg(String time, int userId, String content) async {
    final filename = 'msg-$userId';
    _chatUserWidgets.add(Text(
      filename,
      key: ValueKey(filename),
    ));
    setState(() {});
  }

  _loadMessages() {
    for (final filename in _msgFiles) {
      final file = File('${u.cachePath}/$filename');
      if (!file.existsSync()) {
        continue;
      }
      final messages = file.readAsLinesSync();
      _chatUserWidgets.add(Text(
        filename,
        key: ValueKey(filename),
      ));
      for (final msgInfo in messages) {
        final a = jsonDecode(msgInfo);
        print(a);
      }
    }
    setState(() {});
  }
}
