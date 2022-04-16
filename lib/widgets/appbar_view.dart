import 'package:flutter/material.dart';

_selectView(IconData icon, String text, String id) {
  return PopupMenuItem<String>(
      value: id,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(icon),
          Text(text),
        ],
      ));
}

appBarView(String name) {
  return AppBar(
    toolbarHeight: 45,
    backgroundColor: Colors.white,
    foregroundColor: Colors.brown,
    title: Text(name),
    centerTitle: true,
    elevation: 0,
    actions: [
      PopupMenuButton<String>(
        itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
          _selectView(Icons.message, '发起群聊', 'A'),
          _selectView(Icons.group_add, '添加服务', 'B'),
          _selectView(Icons.cast_connected, '扫一扫码', 'C'),
        ],
        onSelected: (String action) {
          // 点击选项的时候
          switch (action) {
            case 'A':
              break;
            case 'B':
              break;
            case 'C':
              break;
          }
        },
      ),
    ],
  );
}
