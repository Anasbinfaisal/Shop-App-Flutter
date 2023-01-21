import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import './product.dart';
import 'product.dart';
import 'dart:convert';

class Products with ChangeNotifier {
  final String authtoken;
  final String userID;
  Products(this._items, this.authtoken, this.userID);

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  //  var url =
  //     'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authtoken';

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authtoken',
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userID,
          // 'isFavorite': product.isFavorite,
        }),
      );
      var newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    // }).catchError((error) {

    // });
  }

  Future<void> updateProduct(String id, Product product) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final url =
          'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authtoken';
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            // 'isFavorite': product.isFavorite,
          }));
      _items[index] = product;
      notifyListeners();
    } else {
      print('..');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authtoken';

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var exisitingProduct = _items[existingProductIndex];

    // _items.removeWhere((element) => element.id == id);
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, exisitingProduct);
      notifyListeners();
      throw HttpException('Could not delete product!');
    }

    exisitingProduct = null;
  }

  Future<void> fetchProducts([bool filterByuser = false]) async {
    final filterString =
        filterByuser ? 'orderBy="creatorId"&equalTo="$userID"' : '';

    try {
      final response = await http.get(
          'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authtoken&$filterString');
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }

      final favResponse = await http.get(
          'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userID.json?auth=$authtoken');

      final favData = json.decode(favResponse.body);

      final List<Product> loadedProds = [];
      data.forEach((key, value) {
        loadedProds.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl'],
            isFavorite: favData == null ? false : favData[key] ?? false,
          ),
        );
      });
      _items = loadedProds;
      notifyListeners();
    } catch (er) {
      print(er);
    }
  }
}
