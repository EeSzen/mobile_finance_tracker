import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/data/enums/income_category.dart';

class Revenue {
  final int amountCents;
  final IncomeCategory category;
  final String source;
  final DateTime timestamp;

  Revenue({
    required this.amountCents,
    required this.category,
    this.source = '',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'amountCents': amountCents,
        'category': category.name, // store enum name
        'source': source,
        'timestamp': timestamp,
      };

  factory Revenue.fromMap(Map<String, dynamic> map) => Revenue(
    amountCents: map['amountCents'],
    category: incomeCategoryFromString(map["category"]),
    source: map['source'] ?? '',
    timestamp: (map['timestamp'] as Timestamp).toDate(),
  );

  double get amount => amountCents / 100;
}
