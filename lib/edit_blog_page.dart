import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class EditBlogPage extends StatefulWidget {
  const EditBlogPage({Key? key}) : super(key: key);

  @override
  _EditBlogPageState createState() => _EditBlogPageState();
}

class _EditBlogPageState extends State<EditBlogPage> {
  final _sendImg = <Image>[];

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
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
          // 图片列表
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: _sendImg.length + 1,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, final int physicIdx) {
                if (physicIdx == _sendImg.length) {
                  return Card(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _sendImg.add(Image.file(File(image.path)));
                          });
                        }
                      },
                      child: Container(
                        width: 100,
                        child: const Icon(Icons.add),
                        color: Colors.red,
                      ),
                    ),
                  );
                } else {
                  return _sendImg[physicIdx];
                }
              },
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: TextField(
              controller: controller,
              maxLength: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
      // 底部发布按钮
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.fromLTRB(30, 0, 10, 0),
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: const [Icon(Icons.mail), Text("存草稿")],
                  ),
                ),
                color: Colors.red,
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 30, 0),
                color: Colors.blue,
                child: ElevatedButton(
                  style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
                  child: const Text('发布动态'),
                  onPressed: () {
                    uploadBlog(controller.text);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  uploadBlog(String title) async {
    const url = 'http://0--0.top/apis/upload_activity';
    var result = "";

    final picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);

    String path = image != null ? image.path : '';
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);

    var formData = FormData.fromMap({
      'authorName': 'admin',
      'title': title,
      'mainImg': await MultipartFile.fromFile(path, filename: name),
    });

    try {
      var response = await Dio().post(url, data: formData);
      result = response.toString();
    } catch (e) {
      result = '[Error Catch]' + e.toString();
    }
    Fluttertoast.showToast(msg: result);
  }
}
