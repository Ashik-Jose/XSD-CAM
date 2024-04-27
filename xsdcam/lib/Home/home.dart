import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xsdcam/Capture/imgCapture.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List file = [];
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

  // Future<String> get _localPath async {
  //   final directory = await getApplicationDocumentsDirectory();

  //   return directory.path;
  // }

  // Future<File> get _localFile async {
  //   final path = await _localPath;
  //   return File('$path/counter.txt');
  // }

  List getJpgFiles(List filePaths) {
    return filePaths
        .where((path) => path.toString().toLowerCase().endsWith('.jpg\''))
        .map((path) => path.toString().replaceAll('\'', '').split('/').last)
        .toList();

  }

  @override
  Widget build(BuildContext context) {
    List images = getJpgFiles(file);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _listofFiles();
                });
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
