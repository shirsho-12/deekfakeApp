import 'dart:convert';
import 'dart:io';
import 'dart:developer' as devtools show log;

import 'package:equatable/equatable.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gan_deepfake/services/flask_api.dart';

part 'flask_event.dart';
part 'flask_state.dart';

class FlaskBloc extends Bloc<FlaskEvent, FlaskState> {
  FlaskBloc() : super(const HomeState()) {
    on<SelectSourceImageEvent>(_onSelectSourceImageEvent);
    on<SelectReferenceImageEvent>(_onSelectReferenceImageEvent);
    on<CropSourceImageEvent>(_onCropSourceImageEvent);
    on<UpdateSourceImageEvent>(_onUpdateSourceImageEvent);
    on<GenerateOutputImageEvent>(_onGenerateOutputImageEvent);
    on<ShowOutputImageEvent>(_onShowOutputImageEvent);
    on<SaveOutputImageEvent>(_onSaveOutputImageEvent);
  }

  void _onSelectSourceImageEvent(
      SelectSourceImageEvent event, Emitter<FlaskState> emit) async {
    FilePickerCross myFile = await FilePickerCross.importFromStorage(
      type: FileTypeCross.image,
    );
    if (myFile.path != null) {
      emit((state as HomeState).copyWith(sourceImagePath: myFile.path!));
    } else {
      emit((state as HomeState).copyWith(sourceImagePath: ""));
    }
  }

  void _onSelectReferenceImageEvent(
      SelectReferenceImageEvent event, Emitter<FlaskState> emit) async {
    FilePickerCross myFile = await FilePickerCross.importFromStorage(
      type: FileTypeCross.image,
    );
    if (myFile.path != null) {
      emit((state as HomeState).copyWith(referenceImagePath: myFile.path!));
    } else {
      emit((state as HomeState).copyWith(referenceImagePath: ""));
    }
  }

  void _onCropSourceImageEvent(
      CropSourceImageEvent event, Emitter<FlaskState> emit) async {
    var response = await StarGanModel.alignImage(true);
    Map<String, dynamic> data = jsonDecode(response);
    if (data['status'] == 'ok') {
      String outputPath = 'assets/src/img/${data["filename"]}';
      emit((state as HomeState).copyWith(sourceImagePath: outputPath));
    }
    // emit(const TrainingState());
  }

  void _onUpdateSourceImageEvent(
      UpdateSourceImageEvent event, Emitter<FlaskState> emit) {
    emit(HomeState(referenceImagePath: event.sourceImagePath));
  }

  void _onGenerateOutputImageEvent(
      GenerateOutputImageEvent event, Emitter<FlaskState> emit) async {
    var response = await StarGanModel.generateImage();
    Map<String, dynamic> data = jsonDecode(response);
    if (data['status'] == 'ok') {
      String outputPath = 'assets/${data["filename"]}';
      File file = File(outputPath);
      FilePickerCross outputFile = FilePickerCross(file.readAsBytesSync());
      outputFile.saveToPath(path: "temp/output.png");
      devtools.log(outputPath);
      add(const ShowOutputImageEvent(outputImagePath: "temp/output.png"));
    } else {
      devtools.log("Error: ${data['message']}");
    }

    // emit(const TrainingState());
  }

  void _onShowOutputImageEvent(
      ShowOutputImageEvent event, Emitter<FlaskState> emit) {
    // emit(HomeState(outputImagePath: event.outputImagePath));
    emit(HomeState(
        sourceImagePath: (state as HomeState).sourceImagePath,
        referenceImagePath: (state as HomeState).referenceImagePath,
        outputImagePath: event.outputImagePath));
  }

  void _onSaveOutputImageEvent(
      SaveOutputImageEvent event, Emitter<FlaskState> emit) async {
    FilePickerCross outputFile =
        await FilePickerCross.fromInternalPath(path: "temp/output.png");
    outputFile.exportToStorage();
    // emit(const TrainingState());
  }
}
