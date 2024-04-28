import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:xsdcam/Home/home.dart';

String userId='';
String generateRandomString(int length) {
  var random = Random.secure();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(length, (index) => chars[random.nextInt(chars.length)])
      .join();
}

String createKey(String imgName) {
  int nameLength = imgName.length;
  imgName=userId+imgName;
  String altWord = '';
  String resultKey = '';
  int nameChar = 0;
  for (int i = 0; i < imgName.length; i += 2) {
    altWord += imgName[i];
  }
  for (int i = 0; i < altWord.length; i++) {
    nameChar = altWord.codeUnitAt(i);
    nameChar = (nameChar + nameLength) % 26;
    resultKey += String.fromCharCode(nameChar + 97);
  }

  var bytes = utf8.encode(resultKey);
  var hashResult = sha256.convert(bytes);

  return hashResult.toString();
}

saveImageModal(BuildContext context,XFile file,Directory dir)  {
  String imgName = 'img_${generateRandomString(7)}.jpg';
  return AlertDialog(
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0))),
    title: const Text('Enter Image details',style: TextStyle(fontWeight: FontWeight.bold),),
    content:Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Name your Image',
        ),
        TextField(
          controller: TextEditingController(text: imgName),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
          ),
          onChanged: (value) => imgName = value,
        ),
      ],
    ),
    contentPadding: const EdgeInsets.all(10.0),
    actions: <Widget>[
      Center(
        child: TextButton(
          onPressed: () async {
            File file1 = File(path.join(dir.path, imgName));
            String key = createKey(imgName.split('.jpg')[0]);
            var crypt = AesCrypt(key);
            crypt.setOverwriteMode(AesCryptOwMode.on);
            Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 50, // Adjust the quality as needed
      );
            String encrFile=await crypt.encryptDataToFile( compressedImage!, file1.path);
            print(encrFile);
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(context,  MaterialPageRoute(builder: (context) => Home()),(Route<dynamic> route) => false);
          },
          child: const Text(
            'Save',
          ),
        ),
      ),
    ],
  );
}
