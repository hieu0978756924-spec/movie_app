import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LocalJsonService {
  Future<List<dynamic>> loadJsonList(String path) async {
    try {
      final String response = await rootBundle.loadString(path);
      final data = json.decode(response);
      if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> loadJsonMap(String path) async {
    try {
      final String response = await rootBundle.loadString(path);
      final data = json.decode(response);
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
