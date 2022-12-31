import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class SharedData {
  static late final SharedPreferences instance;
  static Future<SharedPreferences> init() async {
    instance = await SharedPreferences.getInstance();
    // instance.clear();
    return instance;
  }

  static void clear() {
    instance.clear();
  }

  // Image Paths
  static String get sourcePath =>
      instance.getString(SettingsKeys.keySourceImage) ?? '';
  static Future<void> setSourcePath(String path) async {
    await instance.setString(SettingsKeys.keySourceImage, path);
  }

  static String get referencePath =>
      instance.getString(SettingsKeys.keyReferenceImage) ?? '';
  static Future<void> setReferencePath(String path) async {
    await instance.setString(SettingsKeys.keyReferenceImage, path);
  }

  static String get outputPath =>
      instance.getString(SettingsKeys.keyOutputImage) ?? '';
  static Future<void> setOutputPath(String path) async {
    await instance.setString(SettingsKeys.keyOutputImage, path);
  }

  // Model Architecture
  static String get numDomains =>
      instance.getString(SettingsKeys.numDomains) ?? '';
  static Future<void> setNumDomains(String path) async {
    await instance.setString(SettingsKeys.numDomains, path);
  }

  static String get latentDims =>
      instance.getString(SettingsKeys.latentDims) ?? '';
  static Future<void> setLatentDims(String path) async {
    await instance.setString(SettingsKeys.latentDims, path);
  }

  static String get hiddenDims =>
      instance.getString(SettingsKeys.hiddenDims) ?? '';
  static Future<void> sethiddenDims(String path) async {
    await instance.setString(SettingsKeys.hiddenDims, path);
  }

  static String get numLayers =>
      instance.getString(SettingsKeys.styleDims) ?? '';
  static Future<void> setStyleDims(String path) async {
    await instance.setString(SettingsKeys.styleDims, path);
  }

  // Training
  static String get numIters => instance.getString(SettingsKeys.numIters) ?? '';
  static Future<void> setNumIters(String path) async {
    await instance.setString(SettingsKeys.numIters, path);
  }

  static String get learningRate =>
      instance.getString(SettingsKeys.learningRate) ?? '';
  static Future<void> setLearningRate(String path) async {
    await instance.setString(SettingsKeys.learningRate, path);
  }

  static String get batchSize =>
      instance.getString(SettingsKeys.batchSize) ?? '8';
  static Future<void> setBatchSize(String path) async {
    await instance.setString(SettingsKeys.batchSize, path);
  }

  // Dark Mode
  static bool get darkMode =>
      instance.getBool(SettingsKeys.keyDarkMode) ?? false;
  static Future<void> setDarkMode(bool darkMode) async {
    await instance.setBool(SettingsKeys.keyDarkMode, darkMode);
  }
}
