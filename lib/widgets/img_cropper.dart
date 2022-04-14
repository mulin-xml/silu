import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';

Future<Uint8List?> imgCropper(context, {double? aspectRatio}) async {
  Uint8List? imageByte = await (await ImagePicker().pickImage(source: ImageSource.gallery))?.readAsBytes();
  if (imageByte == null) {
    // 空表示没选择图片就返回
    return null;
  }

  Uint8List? img = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
    final cropController = CropController();
    var isCropping = false;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
        actions: [
          ElevatedButton(
            child: const Text("选择图片"),
            onPressed: () {
              if (!isCropping) {
                isCropping = true;
                cropController.crop();
              }
            },
          ),
        ],
      ),
      body: Crop(
        image: imageByte,
        controller: cropController,
        onCropped: (image) {
          Navigator.of(context).pop(image);
        },
        withCircleUi: false,
        baseColor: Colors.black,
        maskColor: Colors.black.withAlpha(150),
        cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.white54),
        aspectRatio: aspectRatio,
      ),
    );
  }));
  return img;
}
