import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';

String generateRandomString(int length) {
  var random = Random.secure();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(length, (index) => chars[random.nextInt(chars.length)])
      .join();
}

String createKey(String imgName) {
  String altWord = '';
  String resultKey = '';
  int nameLength = imgName.length;
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

saveImageModal(BuildContext context,XFile file) async {
  Directory dir = await getApplicationDocumentsDirectory();

  String imgName = 'img_${generateRandomString(7)}.jpg';
  return AlertDialog(
    title: const Text('Enter Image details'),
    content: Column(
      children: [
        const Text(
          'Name your Image',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          // keyboardType: TextInputType.text,
          obscureText: true,
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
            String key = createKey(imgName);
            var crypt = AesCrypt(key);
            crypt.setOverwriteMode(AesCryptOwMode.on);
            Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 50, // Adjust the quality as needed
      );
            await crypt.encryptDataToFile( compressedImage, file1.toString());
            Navigator.pop(context);
          },
          child: const Text(
            'Save',
          ),
        ),
      ),
    ],
  );
}
