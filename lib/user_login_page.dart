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
  final _phoneNumController = TextEditingController();
  final _verifyController = TextEditingController();
  var _isReadProtocol = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 手机号输入栏
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: Text("登录后更精彩", textScaleFactor: 2.5),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 50, 50, 0),
            child: TextField(
              controller: _phoneNumController,
              keyboardType: TextInputType.phone,
              maxLength: 11,

              // decoration: const InputDecoration(
              //   hintText: "请输入手机号码",
              //   border: OutlineInputBorder(
              //     borderRadius: BorderRadius.all(Radius.circular(30)),
              //     borderSide: BorderSide.none,
              //   ),
              //   filled: true,
              //   fillColor: Colors.white,
              // ),
              decoration: const InputDecoration(hintText: "请输入手机号码"),
            ),
          ),
          // 验证码输入栏
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 10, 50, 0),
            child: TextField(
              controller: _verifyController,
              // decoration: const InputDecoration(
              //   hintText: "请输入验证码",
              //   border: OutlineInputBorder(
              //     borderRadius: BorderRadius.all(Radius.circular(30)),
              //     borderSide: BorderSide.none,
              //   ),
              //   filled: true,
              //   fillColor: Colors.white,
              // ),
              decoration: const InputDecoration(hintText: "请输入验证码"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 10, 50, 0),
            child: Row(
              children: [
                Container(
                  color: Colors.red,
                  child: Checkbox(
                      shape: const CircleBorder(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _isReadProtocol,
                      onChanged: (value) {
                        setState(() {
                          _isReadProtocol = !_isReadProtocol;
                        });
                      }),
                ),
                const Expanded(child: Text('我已阅读并同意用户协议和隐私政策和儿童/青少年个人信息保护规则', textScaleFactor: 0.8)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(50, 10, 50, 0),
            child: ElevatedButton(
              style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
              child: const Text('登录', textScaleFactor: 1.5),
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
