import 'package:fintrack/data/enums/income_category.dart';
import 'package:fintrack/data/model/revenue.dart';
import 'package:fintrack/data/repo/services/revenue_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditRevenueScreen extends StatefulWidget {
  final String revenueId;
  const EditRevenueScreen({super.key, required this.revenueId});

  @override
  State<EditRevenueScreen> createState() => _EditRevenueScreenState();
}

class _EditRevenueScreenState extends State<EditRevenueScreen> {
  final service = RevenueService();

  final amountController = TextEditingController();
  final sourceController = TextEditingController();
  bool loading = false;
  bool deleting = false;

  IncomeCategory? _selectedIncomeCategory;
  DateTime? _selectedDate;

  Revenue? _originalRevenue; // Store the fetched revenue

  @override
  void initState() {
    super.initState();
    _loadRevenue(); // Fetch data when screen opens
  }

  // Load Revenue data
  Future<void> _loadRevenue() async {
    try {
      final revenue = await service.getRevenueById(widget.revenueId);

      if (revenue == null) {
        if (!mounted) return;
        _showError('Revenue not found');
        context.pop();
        return;
      }

      setState(() {
        _originalRevenue = revenue;
        amountController.text = revenue.amount.toString();
        sourceController.text = revenue.source;
        _selectedIncomeCategory = revenue.category;
        _selectedDate = revenue.timestamp;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load revenue: $e');
      context.pop();
    }
  }

  // Update Revenue
  Future<void> _updateRevenue() async {
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
      final updatedRevenue = Revenue(
        docId: widget.revenueId,
        amountCents: (amount * 100).round(),
        category: _selectedIncomeCategory!,
        source: sourceController.text.trim(),
        timestamp: _selectedDate!,
      );

      await service.updateRevenue(widget.revenueId, updatedRevenue);

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

  // Delete Revenue
  Future<void> _deleteRevenue() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Revenue'),
        content: const Text('Are you sure you want to delete this revenue?'),
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
      await service.deleteRevenue(widget.revenueId);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while fetching
    if (_originalRevenue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Revenue')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Revenue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: deleting ? null : _deleteRevenue,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            _containerCard(title: "Category", child: _buildCategorySelector()),

            const SizedBox(height: 16),

            _buildDatePicker(context),

            const SizedBox(height: 16),

            TextField(
              controller: sourceController,
              minLines: 3,
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                labelText: "Source (optional)",
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Update button instead of Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _updateRevenue,
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

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      children: IncomeCategory.values.map((cat) {
        final selected = cat == _selectedIncomeCategory;
        return ChoiceChip(
          label: Text(cat.label),
          avatar: Icon(cat.icon, size: 18),
          selected: selected,
          onSelected: (_) => setState(() => _selectedIncomeCategory = cat),
        );
      }).toList(),
    );
  }
}
