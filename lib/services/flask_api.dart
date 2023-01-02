import 'dart:convert';
import 'package:gan_deepfake/constants.dart';
import 'package:gan_deepfake/shared.dart';
import 'package:http/http.dart';
import 'dart:developer' as devtools show log;

class FlaskAPI {
  static const String _baseUrl = 'http://127.0.0.1:5000/';

  static Future<String> get(String url) async {
    final response = await Client().get(Uri.parse(url));
    devtools.log(response.body);
    return response.body;
  }

  // Future getData(url) async {
  //   Response response = await get(url);
  //   return response.body;
  // }

  Future postData(url, {required Map body}) async {
    Response response = await post(url, body: body);
    return response.body;
  }

  Future putData(url, {required Map body}) async {
    Response response = await put(url, body: body);
    return response.body;
  }

  Future deleteData(url) async {
    Response response = await delete(url);
    return response.body;
  }

  Future patchData(url, {required Map body}) async {
    Response response = await patch(url, body: body);
    return response.body;
  }

  Future headData(url) async {
    Response response = await head(url);
    return response.body;
  }

  Future run(String mode) async {
    Constants cache = Constants();
    var query = {
      'mode': mode,
      SettingsKeys.numDomains: cache.numDomains,
      SettingsKeys.latentDims: cache.latentDims, // Latent dimensions
      SettingsKeys.styleDims: cache.styleDims, // Style dimensions
      SettingsKeys.hiddenDims: cache.hiddenDims, // Hidden dimensions
      // Training settings
      SettingsKeys.batchSize: cache.batchSize,
      SettingsKeys.numIters: cache.numIters, // Total iters for training
      SettingsKeys.learningRate: cache.learningRate, // Learning rate

      // Image paths
      SettingsKeys.keySourceImage: SharedData.sourcePath,
      SettingsKeys.keyReferenceImage: SharedData.referencePath,
    };

    var data = await get(_baseUrl);
    var decodedData = jsonDecode(data);
    devtools.log(decodedData['query']);
  }
}

// Flask API Demo
void main() async {
  FlaskAPI api = FlaskAPI();
  await api.run('sample');
}
