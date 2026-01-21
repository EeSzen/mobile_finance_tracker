import 'package:fintrack/data/enums/expenses_category.dart';
import 'package:fintrack/data/model/expense.dart';
import 'package:fintrack/data/repo/services/expenses_service.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final service = ExpenseService();

  final amountCentsController = TextEditingController();
  final noteController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  final DateTime _selectedDate = DateTime.now();

  Future<void> _saveExpense() async {
  final amountText = amountCentsController.text.trim();

  if (amountText.isEmpty) {
    return;
  }

  final amount = int.tryParse(amountText);
  if (amount == null || amount <= 0) {
    return;
  }

  final expense = Expense(
    amountCents: amount,
    category: _selectedCategory,
    note: noteController.text.trim(),
    timestamp: _selectedDate,
  );

  await service.addExpense(expense);

  if (!mounted) return;
  Navigator.pop(context);
}

  Widget _buildCategorySelector() {
  return Wrap(
    spacing: 8,
    children: ExpenseCategory.values.map((category) {
      final isSelected = category == _selectedCategory;

      return ChoiceChip(
        label: Text(category.label),
        avatar: Icon(category.icon, size: 18),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedCategory = category);
        },
      );
      }).toList(),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountCentsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (cents)',
              ),
            ),
            const SizedBox(height: 16),

            const Text('Category'),
            const SizedBox(height: 8),
            _buildCategorySelector(),

            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExpense,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
