import 'dart:convert';

class WaterRecord {
  final String id;
  final int amount;
  final String time;

  WaterRecord({
    required this.id,
    required this.amount,
    required this.time,
  });

  factory WaterRecord.fromJson(Map<String, dynamic> json) {
    return WaterRecord(
      id: json['id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      time: json['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'amount': amount,
        'time': time,
      };

  static String encode(List<WaterRecord> records) => json.encode(
        records
            .map<Map<String, dynamic>>((record) => record.toJson())
            .toList(),
      );

  static List<WaterRecord> decode(String records) =>
      (json.decode(records) as List<dynamic>)
          .map<WaterRecord>(
            (dynamic item) => WaterRecord.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
}
