import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/data/enums/income_category.dart';

class Revenue {
  final String? docId;
  final int amountCents;
  final IncomeCategory category;
  final String source;
  final DateTime timestamp;

  Revenue({
    this.docId,
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

  factory Revenue.fromMap(Map<String, dynamic> map, {String? docId}) => Revenue(
    docId: docId,
    amountCents: map['amountCents'],
    category: incomeCategoryFromString(map["category"]),
    source: map['source'] ?? '',
    timestamp: (map['timestamp'] as Timestamp).toDate(),
  );

  double get amount => amountCents / 100;

  Revenue copy({
    String? docId,
    int? amountCents,
    IncomeCategory? category,
    String? source,
    DateTime? timestamp,
  }) {
    return Revenue(
      docId: docId ?? this.docId,
      amountCents: amountCents ?? this.amountCents,
      category: category ?? this.category,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
