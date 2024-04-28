import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xsdcam/Capture/previewSaveModal.dart';

class CapturePagState extends StatefulWidget {
  const CapturePagState({super.key});

  @override
  State<CapturePagState> createState() => _CapturePagStateState();
}

class _CapturePagStateState extends State<CapturePagState> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool isLoading = true;
  // bool isRecording = false;

  _initCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.max);
    await _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      print(error);
    });
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          )
        : Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CameraPreview(_cameraController),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: () async {
                      await _cameraController.takePicture().then((XFile file) {
                        if (file != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          title: const Text('Captured Image'),
                                          actions: [
                                            IconButton(
                                                onPressed: () async {
                                                  Directory dir = await getApplicationDocumentsDirectory();
                                                  // await file1.writeAsBytes(await file.readAsBytes()).then((value) => {
                                                  //   Navigator.pop(context),
                                                  //   print('File Saved')
                                                  // });

                                                showDialog(context: context, builder: (context)=>saveImageModal(context, file,dir));
                                                  
                                                },
                                                icon: const Icon(Icons.save))],
                                        ),
                                        body: Center(
                                          child: Image.file(File(file.path)),
                                        ),
                                      )));
                        }
                      });
                    },
                    child: const Icon(Icons.camera_alt_rounded),
                  ),
                ),
              ],
            ),
          );
  }
}
