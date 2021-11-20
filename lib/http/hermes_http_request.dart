
import 'dart:convert';
import 'package:hermes_http/http/hermes_http_client.dart';
import 'package:hermes_http/http/template_sting.dart';
import 'package:hermes_http/json/parser.dart';
import 'package:http/http.dart';

///Use this class to create requests templates
class HermesRequest<RequestBody, ResponseBody> {
  int _attempts = 0;
  final int maxAttempts;
  final HermesHttpClient _client;
  final String _method;
  final String _path;
  final JsonDecoder<ResponseBody> _responseParser;
  final JsonEncoder<RequestBody> _requestEncoder;
  final Map<String, String> headers;

  HermesRequest(this._client, this._method, this._path, this._requestEncoder, this._responseParser, {this.headers = const <String,String>{}, this.maxAttempts = 3}) {
    if(!_path.startsWith('/')) {
      throw Exception("Request template path must start with ' / ' ");
    }
  }

  Future<ResponseBody> call({ Map<String, String> pathParams = const <String,String>{} , RequestBody? body }) async {
    var requestBody = body == null ? "" : jsonEncode(_requestEncoder.toJson(body));
    var response = await _call(pathParams, requestBody);
    int status = response.statusCode;
    int statusFamily = status ~/ 100;

    if(statusFamily == 2) {
      return _responseParser.fromJson(jsonDecode(response.body));
    } else {
      throw HermesRequestError(response.statusCode, _method, response.request!.url.toString(), response.body);
    }

  }

  Future<Response> _call(Map<String, String> pathParams, String body) async {
    try {
      final templateUrl = TemplateString(_path);
      var parsedPath = templateUrl.format(pathParams);

      var request = _client.getBaseRequest(_method, parsedPath);
      headers.forEach((key, value) { 
        request.headers[key] = value;
      });
      request.body = body;

      var response = await _client.makeRequest(request);
      return response;

    } catch(err) {
      _attempts++;
      if(_attempts >= maxAttempts) {
        _attempts = 0;
        rethrow;
      } else {
        var response = await _call(pathParams, body);
        _attempts = 0;
        return response;
      }
    } 
  }

  addHeader(String key, String value) {
    headers[key] = value;
  }

  removeHeader(String key) {
    headers.remove(key);
  }

}

class HermesRequestError implements Exception {
  int status = 0;
  String body = "";
  String uri = "";
  String method = "";

  HermesRequestError(this.status, this.method, this.uri, this.body);
}