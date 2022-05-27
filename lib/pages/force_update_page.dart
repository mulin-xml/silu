// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:app_installer/app_installer.dart';

import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

class ForceUpdatePage extends StatefulWidget {
  const ForceUpdatePage({Key? key}) : super(key: key);

  @override
  State<ForceUpdatePage> createState() => _ForceUpdatePageState();
}

class _ForceUpdatePageState extends State<ForceUpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('点击安装'),
          onPressed: () => installApk(),
        ),
      ),
    );
  }

  installApk() async {
    final rsp = await Dio().download(VersionCheck().downloadUrl, '${u.cachePath}/silu.apk');
    if (rsp.statusCode == SiluResponse.ok) {
      print('download ok');
      
      
      // OpenFile.open('${u.cachePath}/silu.apk');
    } else {
      print('download error');
    }
  }
}
