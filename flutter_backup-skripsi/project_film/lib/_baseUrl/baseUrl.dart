import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// const String baseUrl = 'localhost:1000';
// const String baseUrl = '10.0.2.2:11111'; // INI KHUSUS SIM ANDROID
const String baseUrl = '192.168.100.2:1000'; // INI KHUSUS ANDROID CABLE

class BaseClient {
  var client = http.Client();

  Future<dynamic> login(String endPoint, String email, String password) async {
    var url = Uri.https(baseUrl, '/api$endPoint');
    // var url = Uri.http(baseUrl, '/api$endPoint');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      'email': '$email',
      'password': '$password',
    });

    var response = await client.post(url, headers: headers, body: body,);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<dynamic> register(String endPoint, String email, String username, String password) async {
    var url = Uri.https(baseUrl, '/api$endPoint');
    // var url = Uri.http(baseUrl, '/api$endPoint');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      'email': '$email',
      'name': '$username',
      'password': '$password',
    });

    var response = await client.post(url, headers: headers, body: body,);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<dynamic> changePassword(String endPoint, String oldPassword, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.https(baseUrl, '/api$endPoint');
    // var url = Uri.http(baseUrl, '/api$endPoint');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Bearer': 'Bearer $token',
    };
    final body = jsonEncode({
      'old_password': '$oldPassword',
      'password': '$password',
    });

    var response = await client.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<dynamic> changeNick(String endPoint, String nick) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.https(baseUrl, '/api$endPoint');
    // var url = Uri.http(baseUrl, '/api$endPoint');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Bearer': 'Bearer $token',
    };
    final body = jsonEncode({
      'name': '$nick',
    });

    var response = await client.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<dynamic> getVideo(String endPoint, String limit, String page, String search) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.https(baseUrl, '/api$endPoint', {
    // var url = Uri.http(baseUrl, '/api$endPoint', {
      'limit': limit,
      'page': page,
      'search': search,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Bearer': 'Bearer $token',
    };

    var response = await client.get(url, headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<dynamic> getVideoByID(String endPoint, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.https(baseUrl, '/api$endPoint/$id', {
    // var url = Uri.http(baseUrl, '/api$endPoint/$id', {
      'id': id,});

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Bearer': 'Bearer $token',
    };

    var response = await client.get(url, headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<dynamic> getSearch(String endPoint, String limit, String page, String search, String condition) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.https(baseUrl, '/api$endPoint', {
    // var url = Uri.http(baseUrl, '/api$endPoint', {
      'limit': limit,
      'page': page,
      'search': search,
      'condition': condition,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Bearer': 'Bearer $token',
    };

    var response = await client.get(url, headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }
}