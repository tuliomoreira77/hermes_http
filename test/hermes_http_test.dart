import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_http/http/hermes_http_client.dart';
import 'package:hermes_http/http/hermes_http_request.dart';
import 'package:hermes_http/json/list_json_parser.dart';
import 'package:hermes_http/json/parser.dart';
import 'package:hermes_http/json/void_json.dart';

void main() {
  var fruitClient = FruitClient();
  test('should return the fruit banana', () async {
    Fruit fruit = await fruitClient.getFruit('banana');
    expect(fruit.name.toLowerCase(), 'banana');
  });
}

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
    _getFruit = HermesRequest(
        _client, 'get', '/api/fruit/{fruitName}', VoidJsonEncoder(), Fruit());

    //Create the request using the class ListJsonDecoder to parse the json list
    _getAllFruit = HermesRequest(_client, 'get', '/api/fruit/all',
        VoidJsonEncoder(), ListJsonDecoder<Fruit>(Fruit()));

    //Create the request setting the maxAttemps (retry) to only 1 (defaults 3)
    _addFruit = HermesRequest(
        _client, 'put', '/api/fruit', Fruit(), VoidJsonDecoder(),
        maxAttempts: 1);
  }

  //Creates a call to request
  //Pass any kind of param (path, query) in the path as a map
  Future<Fruit> getFruit(String fruitName) async {
    return await _getFruit.call(pathParams: {'fruitName': fruitName});
  }

  Future<List<Fruit>> getAllFruit() async {
    _getAllFruit.addHeader(
        "Accept", "application/json"); //dinamically set a header to the request
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
  int id = 0;
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
    fruit.nutritions = NutritionDecoder().fromJson(jsonMap['nutritions']);
    return fruit;
  }

  @override
  Map<String, dynamic> toJson(Fruit obj) {
    Map<String, dynamic> map = <String, dynamic>{};

    map['genus'] = obj.genus;
    map['name'] = obj.name;
    map['id'] = obj.id;
    map['family'] = obj.family;
    map['order'] = obj.order;
    map['nutritions'] = NutritionEncoder().toJson(obj.nutritions);

    return map;
  }
}

class Nutrition {
  num carbohydrates = 0;
  num protein = 0;
  num fat = 0;
  num calories = 0;
  num sugar = 0;
}

class NutritionDecoder extends JsonDecoder<Nutrition> {
  @override
  Nutrition fromJson(jsonMap) {
    Nutrition nutrition = Nutrition();
    nutrition.carbohydrates = jsonMap['carbohydrates'];
    return nutrition;
  }
}

class NutritionEncoder extends JsonEncoder<Nutrition> {
  @override
  Map<String, dynamic> toJson(Nutrition obj) {
    Map<String, dynamic> map = <String, dynamic>{};
    map['carbohydrates'] = obj.carbohydrates;
    return map;
  }
}
