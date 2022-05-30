// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';

import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

class ForceUpdatePage extends StatefulWidget {
  const ForceUpdatePage({Key? key}) : super(key: key);

  @override
  State<ForceUpdatePage> createState() => _ForceUpdatePageState();
}

class _ForceUpdatePageState extends State<ForceUpdatePage> {
  double? _currentProgress;
  bool _isDownloading = false;
  bool _isApkExist = false;
  final _localApkPath = '${u.cachePath}/Silu-${VersionCheck().latestVersion}-Android.apk';

  @override
  void initState() {
    super.initState();
    _isApkExist = File(_localApkPath).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('版本更新'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 30), children: [
        Image.asset('images/silu_logo.png', color: Colors.brown, height: 170, fit: BoxFit.cover),
        Center(child: Text('Version ${VersionCheck().latestVersion}', style: const TextStyle(fontSize: 20))),
        const SizedBox(height: 300),
        Visibility(
          visible: _isDownloading,
          child: LinearProgressIndicator(value: _currentProgress),
        ),
        Visibility(
          visible: !_isApkExist,
          child: Center(
            child: ElevatedButton(
              child: Text(_isDownloading ? '下载中' : '点击下载'),
              onPressed: () => _isDownloading ? null : _downloadApk(),
            ),
          ),
        ),
        Visibility(
          visible: _isApkExist,
          child: Center(
            child: ElevatedButton(
              child: const Text('点击安装'),
              onPressed: _installApk,
            ),
          ),
        ),
      ]),
    );
  }

  _downloadApk() async {
    _isDownloading = true;
    if (!File(_localApkPath).existsSync()) {
      final rsp = await Dio().download(
        VersionCheck().downloadUrl,
        _localApkPath,
        onReceiveProgress: (int count, int total) => setState(() => _currentProgress = total.isNegative ? null : count / total),
      );
      if (rsp.statusCode == SiluResponse.ok) {
        setState(() => _isApkExist = true);
        _installApk();
      }
    }
    _isDownloading = false;
  }

  _installApk() {
    if (File(_localApkPath).existsSync()) {
      OpenFile.open(_localApkPath);
    } else {
      Fluttertoast.showToast(msg: '安装包不存在');
    }
  }
}
