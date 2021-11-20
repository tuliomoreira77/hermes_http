
import 'package:hermes_http/http/hermes_http_client.dart';
import 'package:hermes_http/http/hermes_http_request.dart';
import 'package:hermes_http/json/list_json_parser.dart';
import 'package:hermes_http/json/parser.dart';
import 'package:hermes_http/json/void_json.dart';

class FruitClient {

  late HermesHttpClient _client;

  //declares a request with the request body type and the response body type
  late HermesRequest<void, Fruit> _getFruit;

  late HermesRequest<void, List<Fruit>> _getAllFruit;

  late HermesRequest<Fruit, void> _addFruit;

  FruitClient() {
    //Creates a http client with base url and the common headers
    _client = HermesHttpClient("https://www.fruityvice.com/");
    _client.addHeader("Content-Type", "application/json");
    _client.addHeader("Connection", "keep-alive");

    //Creates the request instance
    _getFruit = HermesRequest(_client, 'get', '/api/fruit/{fruitName}', VoidJsonEncoder(), Fruit());

    //Create the request using the class ListJsonDecoder to parse the json list
    _getAllFruit = HermesRequest(_client, 'get', '/api/fruit/all', VoidJsonEncoder(), ListJsonDecoder<Fruit>(Fruit()));

    //Create the request setting the maxAttemps (retry) to only 1 (defaults 3)
    _addFruit = HermesRequest(_client, 'put', '/api/fruit', Fruit(), VoidJsonDecoder(), maxAttempts: 1);
  }

  //Creates a call to request
  //Pass any kind of param (path, query) in the path as a map 
  Future<Fruit> getFruit(String fruitName) async {
    return await _getFruit.call(pathParams: { fruitName: fruitName });
  }

  Future<List<Fruit>> getAllFruit() async {
    _getAllFruit.addHeader("Accept", "application/json"); //dinamically set a header to the request
    return await _getAllFruit.call();
  }

  Future<void> addFruit(Fruit fruit) async {
    await _addFruit.call(body: fruit);
  }

}

//classes that implements json parser and json encoder, 
//its not mandatory parser and encoder interfaces are implemented by the data class itself. 
//the interface can be implemented by another classes
class Fruit implements JsonDecoder<Fruit>, JsonEncoder<Fruit> {
  String genus = "";
  String name = "";
  String id = "";
  String family = "";
  String order = "";
  Nutrition nutritions = Nutrition();

  @override
  Fruit fromJson(dynamic jsonMap) {
    Fruit fruit = Fruit();
    fruit.genus = jsonMap['genus'];
    fruit.name = jsonMap['name'];
    fruit.id = jsonMap['id'];
    fruit.family = jsonMap['family'];
    fruit.order = jsonMap['order'];
    fruit.nutritions = Nutrition().fromJson(jsonMap['nutritions']);
    return fruit;
  }

  @override
  Map<String, dynamic> toJson(Fruit obj) {
    throw UnimplementedError();
  }
}

class Nutrition implements JsonDecoder<Nutrition>, JsonEncoder<Nutrition> {
  String carbohydrates = "";
  String protein = "";
  String fat = "";
  String calories = "";
  String sugar = "";

  @override
  Nutrition fromJson(dynamic jsonMap) {
    Nutrition nutrition = Nutrition();
    nutrition.carbohydrates = jsonMap['carbohydrates'];
    return nutrition;
  }

  @override
  Map<String, dynamic> toJson(Nutrition obj) {
    throw UnimplementedError();
  }
}

