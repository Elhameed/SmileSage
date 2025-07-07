import 'dart:convert';

class BrushingLog {
  final DateTime date;
  final String? photoPath;

  BrushingLog({required this.date, this.photoPath});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'photoPath': photoPath,
      };

  factory BrushingLog.fromJson(Map<String, dynamic> json) => BrushingLog(
        date: DateTime.parse(json['date']),
        photoPath: json['photoPath'],
      );

  static List<BrushingLog> listFromJson(String jsonString) {
    final List<dynamic> data = json.decode(jsonString);
    return data.map((e) => BrushingLog.fromJson(e)).toList();
  }

  static String listToJson(List<BrushingLog> logs) {
    return json.encode(logs.map((e) => e.toJson()).toList());
  }
}
