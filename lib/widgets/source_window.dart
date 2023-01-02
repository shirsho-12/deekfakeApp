import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:gan_deepfake/shared.dart';

class SourceWidget extends StatefulWidget {
  const SourceWidget({Key? key}) : super(key: key);

  @override
  State<SourceWidget> createState() => _SourceWidgetState();
}

class _SourceWidgetState extends State<SourceWidget> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String sourcePath = SharedData.sourcePath;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    width: width,
                    height: height * 0.36,
                    child: sourcePath != "" && File(sourcePath).existsSync()
                        ? Image.file(File(sourcePath))
                        : Container(),
                  ),
                  SizedBox(height: height * 0.01),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // String? path = await SharedData.pickImage();
                            FilePickerCross myFile =
                                await FilePickerCross.importFromStorage(
                              type: FileTypeCross.image,
                            );
                            if (myFile.path != null) {
                              setState(() {
                                sourcePath = myFile.path!;
                                SharedData.setSourcePath(sourcePath);
                              });
                            }
                          },
                          child: const Text(
                            'Pick Source Image',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            //! TODO: Image Crop -> MethodChannel
                          },
                          child: const Text(
                            'Crop Face',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }
}
