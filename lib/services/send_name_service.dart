import 'dart:convert';
import 'dart:io';

import '../model/models.dart';
import '../utils/utils.dart';
import 'package:dio/dio.dart';

import '../main.dart';

class SendNameService {
  final List<NameModel> _items = [];
  final dbHelper = DatabaseHelper.instance;
  List<NameModel> get items {
    return [..._items];
  }

  Future<SuccessResponse?> addName(text, _connectionStatus) async {
    int a = 1;
    try {
      if (_connectionStatus == true) {
        final response = await DioHelper.dio!.post(
          '/sync/saveNames.php',
          data: jsonEncode(
              <String, dynamic>{"name": text.toString(), "status": a}),
          options: Options(validateStatus: (status) => status! < 500),
        );

        if (response.statusCode == HttpStatus.ok) {
          var decoded = jsonDecode(response.data);
          Map<String, dynamic> row = {
            DatabaseHelper.columnName: text.toString(),
            DatabaseHelper.status: a,
          };
          await dbHelper.insert(row);
          return SuccessResponse.fromJson(decoded);
        } else {
          throw ErrorResponse(
            statusMessage: globals["${response.statusCode}"].toString(),
            statusCode: response.statusCode,
          );
        }
      } else {
        Map<String, dynamic> row = {
          DatabaseHelper.columnName: text.toString(),
          DatabaseHelper.status: 0,
        };
        final id = await dbHelper.insert(row);
        logger.d('inserted row id: $id');
        throw ErrorResponse(
          statusMessage: "Sedang Offline! Data tetap tersimpan.",
          statusCode: 400,
        );
      }
    } catch (e) {
      //jika wifi no intenet
      if (e is TypeError) {
        throw ErrorResponse(
          statusCode: HttpStatus.serviceUnavailable,
          statusMessage: 'Service Unavailable',
        );
      }

      if (e is! DioError) rethrow;

      final error = e.error;
      if (error is SocketException) {
        throw ErrorResponse(
          statusCode: HttpStatus.serviceUnavailable,
          statusMessage: 'Service Unavailable',
        );
      }

      if (error is HandshakeException) {
        throw ErrorResponse(
          statusCode: HttpStatus.serviceUnavailable,
          statusMessage: "Cannot connect securely to server."
              " Please ensure that the server has a valid SSL configuration.",
        );
      }

      throw ErrorResponse(statusMessage: error.message);
    }
  }

  Future<SuccessResponse?> sync(text, _connectionStatus) async {
    int a = 1;
    try {
      if (_connectionStatus == true) {
        final response = await DioHelper.dio!.post(
          '/sync/saveNames.php',
          data: jsonEncode(
              <String, dynamic>{"name": text.toString(), "status": a}),
          options: Options(validateStatus: (status) => status! < 500),
        );

        if (response.statusCode == HttpStatus.ok) {
          var decoded = jsonDecode(response.data);
          return SuccessResponse.fromJson(decoded);
        } else {
          throw ErrorResponse(
            statusMessage: globals["${response.statusCode}"].toString(),
            statusCode: response.statusCode,
          );
        }
      } else {}
    } catch (e) {
      //jika wifi no intenet
      if (e is TypeError) {
        throw ErrorResponse(
          statusCode: HttpStatus.serviceUnavailable,
          statusMessage: 'Service Unavailable',
        );
      }

      if (e is! DioError) rethrow;

      final error = e.error;
      if (error is SocketException) {
        throw ErrorResponse(
          statusCode: HttpStatus.serviceUnavailable,
          statusMessage: 'Service Unavailable',
        );
      }

      if (error is HandshakeException) {
        throw ErrorResponse(
          statusCode: HttpStatus.serviceUnavailable,
          statusMessage: "Cannot connect securely to server."
              " Please ensure that the server has a valid SSL configuration.",
        );
      }

      throw ErrorResponse(statusMessage: error.message);
    }
    return null;
  }
}
