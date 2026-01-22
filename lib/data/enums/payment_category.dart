import "package:flutter/material.dart";

extension PaymentCategoryX on PaymentCategory {
  /// Value stored in Firestore
  String get key => name;

  String get label {
    switch (this) {
      case PaymentCategory.cash:
        return "Cash";
      case PaymentCategory.debitCard:
        return "Debit Card";
      case PaymentCategory.creditCard:
        return "Credit Card";
      case PaymentCategory.eWallet:
        return "E-Wallet";
      case PaymentCategory.bankTransfer:
        return "Bank Transfer";
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentCategory.cash:
        return Icons.payments;
      case PaymentCategory.debitCard:
        return Icons.credit_card;
      case PaymentCategory.creditCard:
        return Icons.credit_card_outlined;
      case PaymentCategory.eWallet:
        return Icons.phone_android;
      case PaymentCategory.bankTransfer:
        return Icons.account_balance;
    }
  }
}

PaymentCategory paymentCategoryFromString(String value) {
  return PaymentCategory.values.firstWhere(
    (e) => e.name == value,
    orElse: () => PaymentCategory.cash, // safe fallback
  );
}

enum PaymentCategory {
  cash,
  debitCard,
  creditCard,
  eWallet,
  bankTransfer,
}
