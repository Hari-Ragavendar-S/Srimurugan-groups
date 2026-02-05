import 'package:flutter/material.dart';
import '../constants/colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedSort = 'Latest';
  
  // Sample transaction data - in real app this would come from storage
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'id': 1,
      'type': 'credit',
      'amount': 5000.0,
      'date': DateTime(2024, 1, 20),
      'description': 'Loan Disbursement',
      'isEMI': false,
    },
    {
      'id': 2,
      'type': 'debit',
      'amount': 1500.0,
      'date': DateTime(2024, 1, 25),
      'description': 'EMI Payment',
      'isEMI': true,
    },
    {
      'id': 3,
      'type': 'credit',
      'amount': 10000.0,
      'date': DateTime(2024, 1, 15),
      'description': 'Loan Disbursement',
      'isEMI': false,
    },
    {
      'id': 4,
      'type': 'debit',
      'amount': 750.0,
      'date': DateTime(2024, 1, 10),
      'description': 'Interest Payment',
      'isEMI': false,
    },
    {
      'id': 5,
      'type': 'debit',
      'amount': 2000.0,
      'date': DateTime(2024, 1, 5),
      'description': 'EMI Payment',
      'isEMI': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);
    
    switch (_selectedSort) {
      case 'Latest':
        filtered.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        break;
      case 'Highest Amount':
        filtered.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
        break;
      case 'EMI only':
        filtered = filtered.where((t) => t['isEMI'] == true).toList();
        filtered.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        break;
      case 'Completed':
        // For demo purposes, showing all transactions as completed
        filtered.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        break;
    }
    
    return filtered;
  }

  Widget _buildSortChip(String label) {
    final isSelected = _selectedSort == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedSort = label;
            });
          }
        },
        backgroundColor: AppColors.white,
        selectedColor: AppColors.goldPrimary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textDarkBrown,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.goldPrimary : AppColors.goldLight,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final date = transaction['date'] as DateTime;
    final description = transaction['description'] as String;
    final isCredit = type == 'credit';
    final isEMI = transaction['isEMI'] as bool;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.goldLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDarkBrown,
                            ),
                          ),
                        ),
                        Text(
                          '${isCredit ? '+' : '-'}Rs ${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCredit ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.darkGrayText,
                          ),
                        ),
                        if (isEMI)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'EMI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDarkBrown,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final date = transaction['date'] as DateTime;
    final description = transaction['description'] as String;
    final isCredit = type == 'credit';
    final isEMI = transaction['isEMI'] as bool;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction #${transaction['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${isCredit ? 'Credit' : 'Debit'}'),
            Text('Amount: Rs ${amount.toStringAsFixed(2)}'),
            Text('Date: ${date.day}/${date.month}/${date.year}'),
            Text('Description: $description'),
            if (isEMI) const Text('Category: EMI Payment'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: AppColors.goldPrimary,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryYellowTop, AppColors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Sort Options
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort by:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDarkBrown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSortChip('Latest'),
                        _buildSortChip('Highest Amount'),
                        _buildSortChip('EMI only'),
                        _buildSortChip('Completed'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Transactions List
            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: AppColors.goldLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.darkGrayText,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) => _buildTransactionCard(transactions[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}