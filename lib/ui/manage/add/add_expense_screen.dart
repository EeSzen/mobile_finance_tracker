import 'package:fintrack/data/enums/expenses_category.dart';
import 'package:fintrack/data/enums/payment_category.dart';
import 'package:fintrack/data/model/expense.dart';
import 'package:fintrack/data/repo/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}



class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final service = ExpenseService();

  final amountCentsController = TextEditingController();
  final noteController = TextEditingController();
  bool loading = false;

  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  PaymentCategory _selectedPayment = PaymentCategory.cash;
  DateTime _selectedDate = DateTime.now();

  // error message showing
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Add Expense Function
  Future<void> _saveExpense() async {
  if (loading) return;

  final amountText = amountCentsController.text.trim();
  if (amountText.isEmpty) {
    _showError('Amount is required');
    return;
  }

  final amount = double.tryParse(amountText);
  if (amount == null) {
    _showError('Enter a valid number');
    return;
  }

  if (amount <= 0) {
    _showError('Amount must be greater than zero');
    return;
  }

  setState(() => loading = true);

  try {
    final amountCents = (amount * 100).round();

    final expense = Expense(
      amountCents: amountCents,
      category: _selectedCategory,
      paymentCategory: _selectedPayment,
      note: noteController.text.trim(),
      timestamp: _selectedDate,
    );

    await service.addExpense(expense);

    if (!mounted) return;
    context.pop();
  } catch (e) {
    _showError(e.toString());
  } finally {
    if (mounted) {
      setState(() => loading = false);
    }
  }
}

  // Reusable Card
  Widget _containerCard({
    required String title,
    required Widget child,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }


  // Date Picker
  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        child: Text(
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  // Category Selector
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

  // Payment Category
  Widget _buildPaymentSelector() {
  return Wrap(
    spacing: 8,
    children: PaymentCategory.values.map((method) {
      final isSelected = method == _selectedPayment;

      return ChoiceChip(
        label: Text(method.label),
        avatar: Icon(method.icon, size: 18),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedPayment = method);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountCentsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Picker
            _containerCard(
              title: "Category", 
              child: _buildCategorySelector()
            ),

            const SizedBox(height: 16),

            // Date Picker
            _buildDatePicker(context),

            const SizedBox(height: 16),

            // Payment Picker
            _containerCard(
              title: "Payment Method", 
              child: _buildPaymentSelector()
            ),

            const SizedBox(height: 16),

            TextField(
              controller: noteController,
              minLines: 3,
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _saveExpense,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
