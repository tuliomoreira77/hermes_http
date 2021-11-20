
import 'package:hermes_http/json/parser.dart';


class ListJsonDecoder<T> extends JsonDecoder<List<T>> {
  JsonDecoder<T> baseParser;

  ListJsonDecoder(this.baseParser);

  @override
  List<T> fromJson(dynamic jsonMap) {
    return jsonMap.map<T>((json) => baseParser.fromJson(json)).toList();
  }
}