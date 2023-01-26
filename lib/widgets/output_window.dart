import 'dart:convert';
import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:gan_deepfake/services/flask_api.dart';
import 'package:gan_deepfake/shared.dart';
import 'dart:developer' as devtools show log;

class OutputWidget extends StatefulWidget {
  const OutputWidget({Key? key}) : super(key: key);

  @override
  State<OutputWidget> createState() => _OutputWidgetState();
}

class _OutputWidgetState extends State<OutputWidget> {
  bool isGenerating = false;

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
                      // Generate Image -> MethodChannel
                      devtools.log("Generate Image", name: "OutputWidget");
                      // final response =
                      //     await StarGanModel.generateImage().then((value) {
                      //   Map<String, dynamic> data = jsonDecode(value);
                      //   if (data['status'] == 'ok') {
                      //     return data["filename"];
                      //   }
                      //   return "sample.jpg";
                      // });
                      setState(() {
                        // outputPath = "assets/sample.jpg";
                        isGenerating = true;
                        // File file = File(outputPath);
                        // FilePickerCross outputFile =
                        // FilePickerCross(file.readAsBytesSync());
                        // outputFile.saveToPath(path: "temp/output.png");
                        // SharedData.setOutputPath(outputPath);
                      });
                    },
                    child: const Text(
                      'Generate',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    height: height * 0.34,
                    child: isGenerating
                        ? FutureBuilder<String>(
                            future: StarGanModel.generateImage(),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return Container();
                                case ConnectionState.active:
                                case ConnectionState.waiting:
                                  return const CircularProgressIndicator();
                                case ConnectionState.done:
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  Map<String, dynamic> data =
                                      jsonDecode(snapshot.data!);
                                  if (data['status'] == 'ok') {
                                    outputPath = 'assets/${data["filename"]}';
                                    File file = File(outputPath);
                                    FilePickerCross outputFile =
                                        FilePickerCross(file.readAsBytesSync());
                                    outputFile.saveToPath(
                                        path: "temp/output.png");
                                    devtools.log(outputPath);
                                    return Image.file(File(outputPath));
                                  }
                                  return Text('Result: ${snapshot.data}');
                              }
                            })
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
