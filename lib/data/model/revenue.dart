import 'package:cloud_firestore/cloud_firestore.dart';

class Revenue {
  final int amountCents;
  final String category;
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
        'category': category,
        'source': source,
        'timestamp': timestamp,
      };

  factory Revenue.fromMap(Map<String, dynamic> map) => Revenue(
        amountCents: map['amountCents'],
        category: map['category'],
        source: map['source'] ?? '',
        timestamp: (map['timestamp'] as Timestamp).toDate(),
      );
}
