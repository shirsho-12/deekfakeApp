import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:gan_deepfake/shared.dart';

class OutputWidget extends StatefulWidget {
  const OutputWidget({Key? key}) : super(key: key);

  @override
  State<OutputWidget> createState() => _OutputWidgetState();
}

class _OutputWidgetState extends State<OutputWidget> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String outputPath = SharedData.outputPath;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      //! TODO: Generate Image -> MethodChannel
                      setState(() {
                        outputPath = SharedData.referencePath;
                        print(outputPath);
                        // outputFile = await FilePickerCross.fromInternalPath(
                        //   path: outputPath,
                        // );
                        File file = File(outputPath);
                        FilePickerCross outputFile =
                            FilePickerCross(file.readAsBytesSync());
                        outputFile.saveToPath(path: "temp/output.png");
                        SharedData.setOutputPath(outputPath);
                      });
                    },
                    child: const Text(
                      'Generate',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    height: height * 0.36,
                    child: outputPath != "" && File(outputPath).existsSync()
                        ? Image.file(File(outputPath))
                        : Container(),
                  ),
                  SizedBox(height: height * 0.01),
                  outputPath != '' && File(outputPath).existsSync()
                      ? Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              FilePickerCross outputFile =
                                  await FilePickerCross.fromInternalPath(
                                      path: "temp/output.png");
                              outputFile.exportToStorage();
                            },
                            child: const Text(
                              'Save Image',
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ));
  }
}
