import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_complete_guide/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token, _userId;
  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    } else
      return null;
  }

  String get userID {
    return _userId;
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final time_to_expiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: time_to_expiry), logout);
  }

  Future<void> _authenticate(
      String email, String pass, String urlSegment) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAa8YAX3ZtboJjiCrRdf-_DRb4gRJVOYvA';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': pass,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      print(json.decode(response.body));
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _userId = extractedData['userId'];
    _expiryDate = extractedData['expiryDate'];
    _token = extractedData['token'];
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> signup(String email, String pass) async {
    return _authenticate(email, pass, 'signUp');

    // String url =
    //     'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAa8YAX3ZtboJjiCrRdf-_DRb4gRJVOYvA';
  }

  Future<void> login(String email, String pass) async {
    return _authenticate(email, pass, 'signInWithPassword');
    //
    // String url =
    //     'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAa8YAX3ZtboJjiCrRdf-_DRb4gRJVOYvA';
    //
  }
}
