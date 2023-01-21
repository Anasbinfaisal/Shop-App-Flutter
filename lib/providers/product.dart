import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  // 'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authtoken',

  Future<void> toggleFavoriteStatus(
      String id, String authToken, String userID) async {
    final oldStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://shop-flutter-db-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userID.json?auth=$authToken'; //$id.json
    try {
      final response = await http.patch(url,
          body: json.encode({
            '$id': isFavorite,
          }));
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (er) {
      print(er);
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
