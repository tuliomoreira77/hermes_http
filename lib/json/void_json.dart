import 'parser.dart';

class VoidJsonDecoder extends JsonDecoder<void> {
  @override
  void fromJson(dynamic jsonMap) {}
}

class VoidJsonEncoder extends JsonEncoder<void> {
  @override
  Map<String, dynamic> toJson(void obj) {
    return <String, dynamic>{};
  }
}
