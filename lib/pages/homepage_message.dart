// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:silu/widgets/appbar_view.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    updatePage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: appBarView('消息'),
      body: RefreshIndicator(
        child: ListView(),
        onRefresh: () async {
          updatePage();
        },
      ),
    );
  }

  updatePage() async {
    setState(() {});
  }
}
