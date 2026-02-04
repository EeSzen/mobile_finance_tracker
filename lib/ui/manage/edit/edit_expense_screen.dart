import 'package:fintrack/data/enums/expenses_category.dart';
import 'package:fintrack/data/enums/payment_category.dart';
import 'package:fintrack/data/model/expense.dart';
import 'package:fintrack/data/repo/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditExpenseScreen extends StatefulWidget {
  final String expenseId;
  const EditExpenseScreen({super.key, required this.expenseId});


  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final service = ExpenseService();
  
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  bool loading = false;
  bool deleting = false;
  
  ExpenseCategory? _selectedCategory;
  PaymentCategory? _selectedPayment;
  DateTime? _selectedDate;
  
  Expense? _originalExpense;  // Store the fetched expense
  
  @override
  void initState() {
    super.initState();
    _loadExpense();  // Fetch data when screen opens
  }

  // Load Expense data
  Future<void> _loadExpense() async {
    try {
      final expense = await service.getExpenseById(widget.expenseId);
      
      if (expense == null) {
        if (!mounted) return;
        _showError('Expense not found');
        context.pop();
        return;
      }
      
      setState(() {
        _originalExpense = expense;
        amountController.text = expense.amount.toString();
        noteController.text = expense.note;
        _selectedCategory = expense.category;
        _selectedPayment = expense.paymentCategory;
        _selectedDate = expense.timestamp;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load expense: $e');
      context.pop();
    }
  }
  
  // Update Expense
  Future<void> _updateExpense() async {
    if (loading) return;
    
    // Same validation as AddExpenseScreen
    final amountText = amountController.text.trim();
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
      final updatedExpense = Expense(
        docId: widget.expenseId,
        amountCents: (amount * 100).round(),
        category: _selectedCategory!,
        paymentCategory: _selectedPayment!,
        note: noteController.text.trim(),
        timestamp: _selectedDate!,
      );
      
      await service.updateExpense(widget.expenseId, updatedExpense);
      
      if (!mounted) return;
      context.pop();
    } catch (e) {
      _showError('Failed to update: $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }
  
  // Delete Expense
  Future<void> _deleteExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => deleting = true);
    
    try {
      await service.deleteExpense(widget.expenseId);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      _showError('Failed to delete: $e');
    } finally {
      if (mounted) {
        setState(() => deleting = false);
      }
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Show loading while fetching
    if (_originalExpense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Expense')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: deleting ? null : _deleteExpense,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountController,
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

            const SizedBox(height: 24),
            
            // Update button instead of Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _updateExpense,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
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
            '${_selectedDate?.year}-${_selectedDate?.month.toString().padLeft(2, '0')}-${_selectedDate?.day.toString().padLeft(2, '0')}',
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
}