import 'package:fintrack/data/enums/income_category.dart';
import 'package:fintrack/data/model/revenue.dart';
import 'package:fintrack/data/repo/services/revenue_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddRevenueScreen extends StatefulWidget {
  const AddRevenueScreen({super.key});

  @override
  State<AddRevenueScreen> createState() => _AddRevenueScreenState();
}

class _AddRevenueScreenState extends State<AddRevenueScreen> {
  final service = RevenueService();
  final amountController = TextEditingController();
  final sourceController = TextEditingController();
  bool loading = false;

  IncomeCategory _selectedCategory = IncomeCategory.salary;
  DateTime _selectedDate = DateTime.now();

  Future<void> _saveRevenue() async {
    if (loading) return;

    final text = amountController.text.trim();
    if (text.isEmpty) {
      _showError("Amount required");
      return;
    }

    final value = double.tryParse(text);
    if (value == null) {
      _showError("Enter a valid amount");
      return;
    }

    if (value <= 0) {
      _showError('Amount must be greater than zero');
      return;
    }

    setState(() => loading = true);
    try {
      final revenue = Revenue(
        amountCents: (value * 100).round(),
        category: _selectedCategory,
        source: sourceController.text.trim(),
        timestamp: _selectedDate,
      );

      await service.addRevenue(revenue);

      if (!mounted) return;
      context.pop();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      children: IncomeCategory.values.map((cat) {
        final selected = cat == _selectedCategory;
        return ChoiceChip(
          label: Text(cat.label),
          avatar: Icon(cat.icon, size: 18),
          selected: selected,
          onSelected: (_) => setState(() => _selectedCategory = cat),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedDate = picked);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Revenue")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: "Amount", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            _containerCard(title: "Category", child: _buildCategorySelector()),

            const SizedBox(height: 16),

            _buildDatePicker(),

            const SizedBox(height: 16),

            TextField(
              controller: sourceController,
              minLines: 3,
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                  labelText: "Source (optional)",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder()),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _saveRevenue,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _containerCard({required String title, required Widget child}) {
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
