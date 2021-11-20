abstract class JsonDecoder<T> {
  T fromJson(dynamic jsonMap);
}

abstract class JsonEncoder<T> {
  Map<String, dynamic> toJson(T obj);
}
