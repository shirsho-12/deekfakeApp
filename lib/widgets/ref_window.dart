import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:gan_deepfake/shared.dart';

class ReferenceWidget extends StatefulWidget {
  const ReferenceWidget({Key? key}) : super(key: key);

  @override
  State<ReferenceWidget> createState() => _ReferenceWidgetState();
}

class _ReferenceWidgetState extends State<ReferenceWidget> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String referencePath = SharedData.referencePath;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    width: width,
                    height: height * 0.36,
                    child: referencePath != ""
                        ? Image.file(File(referencePath))
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
                                referencePath = myFile.path!;
                                SharedData.setReferencePath(referencePath);
                              });
                            }
                          },
                          child: const Text(
                            'Pick Reference Image',
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
