import 'package:flutter/material.dart';

class HistoryItem {
  final String id;
  final DateTime time;
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final IconData icon;

  HistoryItem({
    required this.id,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    required this.icon,
  });
}

