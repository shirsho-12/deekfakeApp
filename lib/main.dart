import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:gan_deepfake/shared.dart';
import 'package:gan_deepfake/widgets/hyperparams.dart';
import 'package:gan_deepfake/widgets/ref_window.dart';
import 'package:gan_deepfake/widgets/source_window.dart';

import 'constants.dart';
import 'widgets/output_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedData.init();
  SharePreferenceCache spCache = SharePreferenceCache();
  await spCache.init();
  await Settings.init(cacheProvider: spCache);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueChangeObserver<bool>(
        cacheKey: SettingsKeys.keyDarkMode,
        defaultValue: SharedData.darkMode,
        builder: (builder, isDarkMode, context) {
          return MaterialApp(
            title: 'DeepFake GAN',
            theme: FlexThemeData.light(
              scheme: FlexScheme.flutterDash,
              surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
              blendLevel: 9,
              subThemesData: const FlexSubThemesData(
                blendOnLevel: 10,
                blendOnColors: false,
              ),
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              // To use the playground font, add GoogleFonts package and uncomment
              // fontFamily: GoogleFonts.notoSans().fontFamily,
            ),
            darkTheme: FlexThemeData.dark(
              scheme: FlexScheme.flutterDash,
              surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
              blendLevel: 15,
              subThemesData: const FlexSubThemesData(
                blendOnLevel: 20,
              ),
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              // To use the Playground font, add GoogleFonts package and uncomment
              // fontFamily: GoogleFonts.notoSans().fontFamily,
            ),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const HomePage(),
          );
        });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeepFake GAN'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                SharedData.clear();
                // Trigger rebuild of all widgets that use the shared data.
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const HomePage();
                }));
              })
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return GridView.builder(
            itemCount: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: constraint.maxWidth / constraint.maxHeight,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SourceWidget();
              } else if (index == 1) {
                return const ReferenceWidget();
              } else if (index == 2) {
                return const OutputWidget();
              } else if (index == 3) {
                return const HyperParams();
              }
              return Container(
                color: Colors.red,
                margin: const EdgeInsets.all(4.0),
              );
            },
          );
        },
      ),
    );
  }
}
