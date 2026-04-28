import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lab1_water/models/water_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterRepository {
  final Dio _dio = Dio()
    ..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (Object object) => debugPrint(object.toString()),
      ),
    );

  final String _url = 'https://aqua-olya-test.free.beeceptor.com/water-history';
  static const String _storageKey = 'cached_water_history';

  Future<List<WaterRecord>> getWaterHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final Response<dynamic> response = await _dio.get(_url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final List<WaterRecord> records = data
            .map(
              (dynamic e) => WaterRecord.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        await prefs.setString(_storageKey, WaterRecord.encode(records));
        return records;
      }
    } catch (e) {
      debugPrint('API Error, switching to offline mode: $e');
      final String? cachedData = prefs.getString(_storageKey);
      if (cachedData != null) {
        return WaterRecord.decode(cachedData);
      }
    }
    return <WaterRecord>[];
  }
}
