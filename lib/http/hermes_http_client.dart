
import 'package:http/http.dart';

///Base abstraction of a http client
abstract class IHermesHttpClient {
  void addHeader(String key, String value);
  void removeHeader(String key);
  Request getBaseRequest(String method, String path);
  Future<Response> makeRequest(BaseRequest request);
}

///Concrete Http Client built on top of http.dart
class HermesHttpClient {

  late String _baseUri;
  final Map<String, String> _baseHeaders = Map();

  HermesHttpClient(baseUri) {
    if(baseUri.endsWith('/')) {
      _baseUri = baseUri.substring(0, baseUri.length - 1);
    }
    _baseUri = baseUri;
  }

  addHeader(String key, String value) {
    _baseHeaders[key] = value;
  }

  removeHeader(String key) {
    _baseHeaders.remove(key);
  }

  Request getBaseRequest(String method, String path) {
    var url = Uri.parse('$_baseUri$path');
    var request = Request(method, url);
    _baseHeaders.forEach((key, value) { 
      request.headers[key] = value;
    });
    request.persistentConnection = false;
    
    return request;
  }

  Future<Response> makeRequest(BaseRequest request) async {
    var client = Client();
    var response = await client.send(request);
    var objectResponse =  await Response.fromStream(response);
    client.close();
    return objectResponse;
  }

}