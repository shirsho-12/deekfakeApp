// BLoC State Management

part of 'flask_bloc.dart';

abstract class FlaskState extends Equatable {
  const FlaskState();

  @override
  List<Object> get props => [];

  FlaskState copyWith();
}

class HomeState extends FlaskState {
  final String sourceImagePath;
  final String referenceImagePath;
  final String outputImagePath;
  const HomeState(
      {this.sourceImagePath = '',
      this.referenceImagePath = '',
      this.outputImagePath = ''});

  @override
  List<Object> get props =>
      [sourceImagePath, referenceImagePath, outputImagePath];

  @override
  HomeState copyWith({
    String? sourceImagePath,
    String? referenceImagePath,
    String? outputImagePath,
  }) {
    return HomeState(
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      referenceImagePath: referenceImagePath ?? this.referenceImagePath,
      outputImagePath: outputImagePath ?? this.outputImagePath,
    );
  }
}

class TrainingState extends FlaskState {
  // final String trainingImagePath;
  // final String trainingOutputImagePath;
  const TrainingState();
  // {this.trainingImagePath = '', this.trainingOutputImagePath = ''});

  @override
  List<Object> get props => [];

  @override
  TrainingState copyWith() {
    return const TrainingState();
  }
}
