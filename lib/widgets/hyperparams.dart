import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:gan_deepfake/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class HyperParams extends StatefulWidget {
  const HyperParams({Key? key}) : super(key: key);

  @override
  State<HyperParams> createState() => _HyperParamsState();
}

class _HyperParamsState extends State<HyperParams> {
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  late final Constants presets;

  @override
  void initState() {
    presets = Constants();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // child: Expanded(
      child: ListView(
        children: [
          SwitchSettingsTile(
            title: "Dark Mode",
            leading: const Icon(Icons.dark_mode),
            settingKey: SettingsKeys.keyDarkMode,
            onChange: (val) {
              setState(() {
                SharedData.setDarkMode(val);
              });
            },
            defaultValue: SharedData.darkMode,
          ),
          SettingsGroup(
            title: "Model Architecture",
            subtitle: "Set the architecture of the model",
            children: [
              // RadioSettingsTile(
              //   title: "Number of Domains",
              //   settingKey: SettingsKeys.numDomains,
              //   values: const {
              //     "1": "1",
              //     "2": "2",
              //     "3": "3",
              //     "4": "4",
              //   },
              //   selected: presets.numDomains.toString(),
              // ),
              RadioSettingsTile(
                title: "Number of Latent Dimensions",
                settingKey: SettingsKeys.latentDims,
                values: const {
                  "2": "2",
                  "4": "4",
                  "8": "8",
                  "16": "16",
                  "32": "32",
                  "64": "64",
                  "128": "128",
                },
                selected: presets.latentDims.toString(),
              ),
              RadioSettingsTile(
                title: "Number of Hidden Dimensions",
                settingKey: SettingsKeys.hiddenDims,
                values: const {
                  "2": "2",
                  "4": "4",
                  "8": "8",
                  "16": "16",
                  "32": "32",
                  "64": "64",
                  "128": "128",
                  "256": "256",
                  "512": "512",
                  "1024": "1024",
                },
                selected: presets.hiddenDims.toString(),
              ),
              RadioSettingsTile(
                title: "Number of Style Dimensions",
                settingKey: SettingsKeys.styleDims,
                values: const {
                  "2": "2",
                  "4": "4",
                  "8": "8",
                  "16": "16",
                  "32": "32",
                  "64": "64",
                  "128": "128",
                  "256": "256",
                },
                selected: presets.styleDims.toString(),
              )
            ],
          ),
          SettingsGroup(
            title: "Model Training Hyperparameters",
            subtitle: "Set the hyperparameters for training the model",
            children: [
              TextInputSettingsTile(
                title: "Learning Rate",
                settingKey: SettingsKeys.learningRate,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter a value between 0 and 1";
                  }
                  if (!isNumeric(val) ||
                      double.parse(val) < 0 ||
                      double.parse(val) > 1) {
                    return "Please enter a number";
                  }
                  return null;
                },
                initialValue: presets.learningRate.toString(),
              ),
              RadioSettingsTile(
                title: "Batch Size",
                settingKey: SettingsKeys.batchSize,
                values: const {
                  "1": "1",
                  "2": "2",
                  "4": "4",
                  "8": "8",
                  "16": "16",
                  "32": "32",
                },
                selected: presets.batchSize.toString(),
              ),
              RadioSettingsTile(
                title: "Number of Iterations",
                settingKey: SettingsKeys.numIters,
                values: const {
                  "50000": "50 000",
                  "100000": "100 000",
                  "200000": "200 000",
                  "250000": "250 000",
                  "400000": "400 000",
                  "500000": "500 000",
                  "800000": "800 000",
                  "1000000": "1 000 000",
                },
                selected: presets.numIters.toString(),
              ),
            ],
          ),
        ],
      ),
      // ),
    );
  }

  bool isNumeric(String val) {
    return double.tryParse(val) != null;
  }
}
