import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xsdcam/Capture/imgCapture.dart';
import 'package:xsdcam/Home/signInScreen.dart';
import 'package:xsdcam/services/auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List file = [];
  String userId='';
  Authentication _auth=Authentication();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listofFiles();
  }

  void _listofFiles() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      file = Directory(directory).listSync();
    });
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

  List getJpgFiles(List filePaths) {
    return filePaths
        .where((path) => path.toString().toLowerCase().endsWith('.jpg\''))
        .map((path) => path.toString().replaceAll('\'', '').split('/').last)
        .toList();
  }

  List getJpgFilesPath(List filePaths) {
    return filePaths
        .where((path) => path.toString().toLowerCase().endsWith('.jpg\''))
        .toList();
  }

  Future<void> deleteFile(String filePath) async {
    try {
      File fileRoute = File(filePath);
      await fileRoute.delete();
      setState(() {
        file.remove(filePath);
        _listofFiles();
      });
      print('File deleted');
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List images = getJpgFiles(file);
    List imagePaths = getJpgFilesPath(file);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () async{
                // setState(() {
                //   _listofFiles();
                // });
                await _auth.signOut();
                Navigator.pushAndRemoveUntil(context,  MaterialPageRoute(builder: (context) => SignInScreen()),(Route<dynamic> route) => false);
              },
            )],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: images.length,
                  itemBuilder: (BuildContext context, int index) {
                    // return Text(file[index].toString());
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        child: ListTile(
                          title: Text(images[index].toString()),
                          trailing: GestureDetector(
                              child: const Icon(Icons.delete_rounded),
                              onTap: ()=> deleteFile(imagePaths[index].path),
                          ),
                          onTap: () async{
                            var crypt = AesCrypt(createKey(images[index].toString().split('.jpg')[0]));
                            crypt.setOverwriteMode(AesCryptOwMode.on);
                            Uint8List decData = await crypt.decryptDataFromFile(imagePaths[index].path);
                            try {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Image.memory(
                                            decData!,
                                            fit: BoxFit.cover,
                                          )));
                            }catch(e)
                            {
                              print(e.toString());
                            }
                          },
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CapturePagState()));
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
        ));
  }
}
