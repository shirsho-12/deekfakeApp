import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gan_deepfake/flask_bloc/flask_bloc.dart';

class ReferenceWidget extends StatelessWidget {
  final String referencePath;
  const ReferenceWidget({super.key, required this.referencePath});

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
                    child:
                        referencePath != "" && File(referencePath).existsSync()
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
                            context
                                .read<FlaskBloc>()
                                .add(const SelectReferenceImageEvent());
                          },
                          child: const Text(
                            'Pick Reference Image',
                          ),
                        ),
                        // ElevatedButton(
                        //   onPressed: () async {
                        //      context
                        //       .read<FlaskBloc>()
                        //       .add(const CropReferenceImageEvent());
                        // },
                        //   },
                        //   child: const Text(
                        //     'Crop Face',
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }
}
