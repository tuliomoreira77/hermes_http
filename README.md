<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A Flutter library to make Rest API clients more easily. Inspired by Java Feing.

## Features

 - Facilitated JSON encode and decode using common interfaces.
 - Facilitated http errors handle.
 - Facilitated http header control.
 - Dynamic generation of urls with path and queries params.
 - Configurable retry attempsts on http error.

## Getting started
Just add the package and follow the instructions
```yaml
dependencies:
  hermes_http: ^1.0.1
```

## Usage

Create a client class and provide default configuration and request templates on constructor;

```dart

class FruitClient {

  late HermesHttpClient _client;

  FruitClient() {
    //Creates a http client with base url and the common headers
    _client = HermesHttpClient("https://www.fruityvice.com/");
    _client.addHeader("Content-Type", "application/json");
    _client.addHeader("Connection", "keep-alive");
  }
  
}
```

Then create the data classes of Requests and Responses, and one implementation of the interfaces JsonDecoder<Response>, JsonEncoder<Request> for each class.
```dart
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
```

Using the data classes create the requests templates. 
For each request template provide an HermesRequest<Request, Response> reference, either the request or response object can be void (if you want to ignore response void just pass void to).
After that instatiate the request template on constructor 
The parameters are:
   - hermes http client (or a custom implementation of the IHermesHttpClient)
   - http method lowercase
   - path with any params inside brackets ( /api/fruit/{fruitName} , /api/fruit/nutrition?min={minumunValue}&max={maximumValue} )
   - an implementation of JsonEncoder<Request> interface (use VoidJsonEncoder() for void values)
   - an implementation of JsonDecoder<Response> interface (use VoidJsonDecoder() for void values)
   - optional named parameter maxAttempts for configure retry (default 3)
   - optional custom headers for the request ( Map<String,String> )
  
```dart
  
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
}
  
```
  
Then just finish exposing methods of the client
```dart
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
    return await _getFruit.call(pathParams: { 'fruitName': fruitName });
  }

  Future<List<Fruit>> getAllFruit() async {
    _getAllFruit.addHeader("Accept", "application/json"); //dinamically set a header to the request
    return await _getAllFruit.call();
  }

  Future<void> addFruit(Fruit fruit) async {
    await _addFruit.call(body: fruit);
  }

}
```
  
The full example can be found on github exemples folder.
  
If the http call return http status diferent of the 2xx family the following exception will be thrown
  
```dart
class HermesRequestError implements Exception {
  int status = 0;
  String body = "";
  String uri = "";
  String method = "";

  HermesRequestError(this.status, this.method, this.uri, this.body);
}
```

## Additional information

Fell free to contribute.
