import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gan_deepfake/flask_bloc/flask_bloc.dart';
// import 'package:gan_deepfake/shared.dart';
// String sourcePath = SharedData.sourcePath;

class SourceWidget extends StatelessWidget {
  final String sourcePath;
  const SourceWidget({Key? key, required this.sourcePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                            context
                                .read<FlaskBloc>()
                                .add(const SelectSourceImageEvent());
                          },
                          child: const Text(
                            'Pick Source Image',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            context
                                .read<FlaskBloc>()
                                .add(const CropSourceImageEvent());
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
