import 'dart:convert';

import 'package:flutter/foundation.dart';
// import 'package:flutter_complete_guide/providers/cart.dart';
import 'cart.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String authtoken;

  Orders(this.authtoken, this._orders, this.userID);

  List<OrderItem> _orders = [];
  final String userID;

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    try {
      final url =
          'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app//orders/$userID.json?auth=$authtoken';
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList(),
          'dateTime': DateTime.now().toIso8601String(),
        }),
      );

      var newOrder = OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts,
      );

      _orders.add(newOrder);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Future<void> addProduct(Product product) async {
  //   try {
  //     final response = await http.post(
  //       url,
  //       body: json.encode({
  //         'title': product.title,
  //         'description': product.description,
  //         'imageUrl': product.imageUrl,
  //         'price': product.price,
  //         'isFavorite': product.isFavorite,
  //       }),
  //     );
  //     var newProduct = Product(
  //         id: json.decode(response.body)['name'],
  //         title: product.title,
  //         description: product.description,
  //         price: product.price,
  //         imageUrl: product.imageUrl);
  //
  //     _items.add(newProduct);
  //     notifyListeners();
  //   } catch (error) {
  //     print(error);
  //     throw error;
  //   }
  //
  //   // }).catchError((error) {
  //
  //   // });
  // }
  //
  // Future<void> updateProduct(String id, Product product) async {
  //   final index = _items.indexWhere((element) => element.id == id);
  //   if (index >= 0) {
  //     final url =
  //         'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json';
  //     await http.patch(url,
  //         body: json.encode({
  //           'title': product.title,
  //           'description': product.description,
  //           'imageUrl': product.imageUrl,
  //           'price': product.price,
  //           'isFavorite': product.isFavorite,
  //         }));
  //     _items[index] = product;
  //     notifyListeners();
  //   } else {
  //     print('..');
  //   }
  // }
  //
  // Future<void> deleteProduct(String id) async {
  //   final url =
  //       'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id';
  //
  //   final existingProductIndex =
  //       _items.indexWhere((element) => element.id == id);
  //   var exisitingProduct = _items[existingProductIndex];
  //
  //   // _items.removeWhere((element) => element.id == id);
  //   _items.removeAt(existingProductIndex);
  //   notifyListeners();
  //
  //   final response = await http.delete(url);
  //   if (response.statusCode >= 400) {
  //     _items.insert(existingProductIndex, exisitingProduct);
  //     notifyListeners();
  //     throw HttpException('Could not delete product!');
  //   }
  //
  //   exisitingProduct = null;
  // }

  Future<void> fetchOrders() async {
    try {
      final url =
          'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json?auth=$authtoken';
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      final List<OrderItem> loadedOrders = [];
      data.forEach((key, value) {
        loadedOrders.add(
          OrderItem(
            id: key,
            amount: value['amount'],
            dateTime: DateTime.parse(value['dateTime']),
            products: (value['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    quantity: item['quantity'],
                    price: item['price'],
                    title: item['title']))
                .toList(),
          ),
        );
      });

      _orders = loadedOrders;
      notifyListeners();
    } catch (er) {
      print(er);
    }
  }
}
