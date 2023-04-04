part of 'flask_bloc.dart';

abstract class FlaskEvent {
  const FlaskEvent();
}

// Select Source Image
class SelectSourceImageEvent extends FlaskEvent {
  const SelectSourceImageEvent();
}

// Select Reference Image
class SelectReferenceImageEvent extends FlaskEvent {
  const SelectReferenceImageEvent();
}

// Crop Source Image -> wait for server
class CropSourceImageEvent extends FlaskEvent {
  const CropSourceImageEvent();
}

// Update Source Image -> output from server
class UpdateSourceImageEvent extends FlaskEvent {
  final String sourceImagePath;
  const UpdateSourceImageEvent({required this.sourceImagePath});
}

// Generate Output Image -> wait for server
class GenerateOutputImageEvent extends FlaskEvent {
  const GenerateOutputImageEvent();
}

// Show Output Image -> output from server
class ShowOutputImageEvent extends FlaskEvent {
  final String outputImagePath;
  const ShowOutputImageEvent({required this.outputImagePath});
}

class SaveOutputImageEvent extends FlaskEvent {
  const SaveOutputImageEvent();
}
