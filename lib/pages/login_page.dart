// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:silu/main.dart';
import 'package:silu/utils.dart';
import 'package:silu/http_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneNumController = TextEditingController();
  final _verifyController = TextEditingController();
  static const _maxCountdownTime = 10;
  var _isReadProtocol = false;
  var _countdownTime = 0;
  var _verifyButtonText = "获取验证码";
  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: Text("登录后更精彩", textScaleFactor: 2.5),
          ),
          // 手机号输入栏
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 50, 50, 0),
            child: TextField(
              controller: _phoneNumController,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              decoration: const InputDecoration(hintText: "请输入手机号码", counterText: ""),
            ),
          ),
          // 验证码输入栏
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 10, 50, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _verifyController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(hintText: "请输入验证码", counterText: ""),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (_countdownTime > 0) {
                      return;
                    } else if (_phoneNumController.text.length < 11) {
                      Fluttertoast.showToast(msg: '请输入完整的手机号');
                      return;
                    }

                    var rsp = await SiluRequest().post('login_phone_step1', {'phone_number': _phoneNumController.text});

                    if (rsp.statusCode == HttpStatus.ok) {
                      Fluttertoast.showToast(msg: '短信验证码已发送，请注意查收');
                      _countdownTime = _maxCountdownTime;
                      _timer = Timer.periodic(
                        const Duration(seconds: 1),
                        (timer) => setState(() {
                          if (_countdownTime <= 0) {
                            _verifyButtonText = '重新获取';
                            timer.cancel();
                          } else {
                            _verifyButtonText = _countdownTime.toString() + 's后重新发送';
                            _countdownTime -= 1;
                          }
                        }),
                      );
                    } else {
                      Fluttertoast.showToast(msg: '短信验证码发送失败');
                    }
                  },
                  child: Text(_verifyButtonText),
                ),
              ],
            ),
          ),
          // 阅读协议勾选
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 30, 50, 0),
            child: Row(
              children: [
                Checkbox(
                  shape: const CircleBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: _isReadProtocol,
                  onChanged: (value) => setState(() => _isReadProtocol = !_isReadProtocol),
                ),
                const Expanded(child: Text('我已阅读并同意用户协议和隐私政策和儿童/青少年个人信息保护规则', textScaleFactor: 0.8)),
              ],
            ),
          ),
          // 登录按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(50, 10, 50, 0),
            child: ElevatedButton(
              style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
              child: const Text('登录', textScaleFactor: 1.5),
              onPressed: () async {
                if (!_isReadProtocol || _phoneNumController.text.length < 11 || _verifyController.text.isEmpty) {
                  Fluttertoast.showToast(msg: '请检查手机号和验证码');
                  return;
                }

                var rsp = await SiluRequest().post('login_phone_step2', {'phone_number': _phoneNumController.text, 'validate_code': _verifyController.text});

                if (rsp.statusCode == HttpStatus.ok) {
                  Fluttertoast.showToast(msg: '登录成功');
                  var sp = u.sharedPreferences;
                  sp.setBool('is_login', true);
                  sp.setString('user_id', rsp.data['user_id'] ?? '-1');
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const MyHomePage()));
                } else {
                  Fluttertoast.showToast(msg: '验证码错误');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
