import 'package:flutter/foundation.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

@immutable
class SettingsKeys {
  static const numIters = 'total_iters';
  static const learningRate = 'learning_rate';
  static const batchSize = 'batch_size';

  // Model Architecture
  static const numDomains = 'num_domains';
  static const latentDims = 'latent_dims';
  static const hiddenDims = 'hidden_dims';
  static const styleDims = 'style_dims';

  static const keyDarkMode = 'dark_mode';

  // Image Paths
  static const keySourceImage = 'source_image';
  static const keyReferenceImage = 'reference_image';
  static const keyOutputImage = 'output_image';
}

class Constants {
  final int numIters = int.parse(
      (Settings.getValue(SettingsKeys.numIters, defaultValue: "100000")!));

  final double learningRate = double.parse((Settings.getValue(
      SettingsKeys.learningRate,
      defaultValue: "0.000001")!));

  final int batchSize = int.parse(
      (Settings.getValue(SettingsKeys.batchSize, defaultValue: "8")!));

  final int numDomains = int.parse(
      (Settings.getValue(SettingsKeys.numDomains, defaultValue: "1")!));

  final int latentDims = int.parse(
      (Settings.getValue(SettingsKeys.latentDims, defaultValue: "16")!));

  final int hiddenDims = int.parse(
      (Settings.getValue(SettingsKeys.hiddenDims, defaultValue: "512")!));

  final int styleDims = int.parse(
      (Settings.getValue(SettingsKeys.styleDims, defaultValue: "64")!));

  final bool darkMode =
      Settings.getValue(SettingsKeys.keyDarkMode, defaultValue: false)!;
}
