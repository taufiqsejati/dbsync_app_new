import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Model/name_model.dart';
import '../database_helper.dart';

class SendNameProvider with ChangeNotifier {
  final List<NameModel> _items = [];
  final dbHelper = DatabaseHelper.instance;
  List<NameModel> get items {
    return [..._items];
  }

  Future<void> addName(text, _connectionStatus) async {
    debugPrint(text.toString());
    int a = 1;
    debugPrint(_connectionStatus.toString());
    try {
      if (_connectionStatus == true) {
        Response response = await Dio().post(
          'http://192.168.0.116/sync/saveNames.php',
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: jsonEncode(
              <String, dynamic>{"name": text.toString(), "status": a}),
        );
        // final http.Response response = await http.post(
        //   ' http://localhost/SqliteSync/saveName.php',
        //   headers: <String, String>{
        //     'Content-Type': 'application/json; charset=UTF-8',
        //   },
        //   body: jsonEncode(<String, dynamic>{
        //     "name": text.toString(),
        //     "status": a
        //   }),
        // );
        if (response.statusCode == 200) {
          String? body = response.statusMessage;
          debugPrint(body);
          Map<String, dynamic> row = {
            DatabaseHelper.columnName: text.toString(),
            DatabaseHelper.status: 1,
          };
          await dbHelper.insert(row);
        } else {
          debugPrint('Request failed with status: ${response.statusCode}.');
        }
      } else {
        Map<String, dynamic> row = {
          DatabaseHelper.columnName: text.toString(),
          DatabaseHelper.status: 0,
        };
        final id = await dbHelper.insert(row);
        debugPrint('inserted row id: $id');
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> sync(text, _connectionStatus) async {
    debugPrint(text.toString());
    int a = 1;
    debugPrint(_connectionStatus.toString());
    try {
      if (_connectionStatus == true) {
        Response response = await Dio().post(
          'http://192.168.0.116/sync/saveNames.php',
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: jsonEncode(
              <String, dynamic>{"name": text.toString(), "status": a}),
        );
        if (response.statusCode == 200) {
          String? body = response.statusMessage;
          debugPrint(body);
        } else {
          debugPrint('Request failed with status: ${response.statusCode}.');
        }
      } else {}

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
