// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart' as dio;

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({Key? key}) : super(key: key);

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final TextEditingController _phoneNumController = TextEditingController();
  final TextEditingController _verifyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 手机号输入栏
          const Text(
            "登录后更精彩",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: TextField(
              controller: _phoneNumController,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              decoration: const InputDecoration(
                hintText: "请输入手机号码",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // 验证码输入栏
          Padding(
            padding: const EdgeInsets.all(30),
            child: TextField(
              controller: _verifyController,
              decoration: const InputDecoration(
                hintText: "请输入验证码",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const Text('我已阅读并同意用户协议和隐私政策'),
          ElevatedButton(
            style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
            child: const Text('登录'),
            onPressed: () async {
              const url = 'http://0--0.top/apis/login_phone_step2';
              var result = "";

              var formData = dio.FormData.fromMap({
                'phoneNumber': _phoneNumController.text,
                'validateCode': _verifyController.text,
              });

              try {
                var response = await dio.Dio().post(url, data: formData);
                result = response.toString();
              } catch (e) {
                result = '[Error Catch]' + e.toString();
              }
              print(result);
              Fluttertoast.showToast(msg: result);
            },
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(shape: const CircleBorder()),
                    onPressed: () async {
                      const url = 'http://0--0.top/apis/login_phone_step1';
                      var result = "";

                      var formData = dio.FormData.fromMap({
                        'phoneNumber': _phoneNumController.text,
                      });

                      try {
                        var response = await dio.Dio().post(url, data: formData);
                        result = response.toString();
                      } catch (e) {
                        result = '[Error Catch]' + e.toString();
                      }
                      print(result);
                      Fluttertoast.showToast(msg: result);
                    },
                    child: const Icon(Icons.storefront),
                  ),
                  const Text("验证码", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}