import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  // Sample loan data - in real app this would come from storage
  final List<Map<String, dynamic>> _loans = [
    {
      'id': 1,
      'amount': 10000.0,
      'startDate': DateTime(2024, 1, 15),
      'closeDate': DateTime(2024, 3, 15),
      'status': 'Active',
    },
    {
      'id': 2,
      'amount': 5000.0,
      'startDate': DateTime(2023, 11, 1),
      'closeDate': DateTime(2024, 1, 1),
      'status': 'Completed',
    },
  ];

  double _calculateInterestPerDay(double loanAmount) {
    return (loanAmount / 10000) * 15;
  }

  int _calculateDaysUsed(DateTime startDate, DateTime closeDate) {
    return closeDate.difference(startDate).inDays;
  }

  double _calculateTotalInterest(double loanAmount, int daysUsed) {
    final interestPerDay = _calculateInterestPerDay(loanAmount);
    return interestPerDay * daysUsed;
  }

  double _calculateTotalPayable(double loanAmount, double totalInterest) {
    return loanAmount + totalInterest;
  }

  Widget _buildLoanCard(Map<String, dynamic> loan) {
    final loanAmount = loan['amount'] as double;
    final startDate = loan['startDate'] as DateTime;
    final closeDate = loan['closeDate'] as DateTime;
    final status = loan['status'] as String;
    
    final interestPerDay = _calculateInterestPerDay(loanAmount);
    final daysUsed = _calculateDaysUsed(startDate, closeDate);
    final totalInterest = _calculateTotalInterest(loanAmount, daysUsed);
    final totalPayable = _calculateTotalPayable(loanAmount, totalInterest);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loan #${loan['id']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkBrown,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'Active' ? Colors.green : AppColors.goldLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: status == 'Active' ? AppColors.white : AppColors.textDarkBrown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Loan Details Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildDetailItem('Loan Amount', 'Rs ${loanAmount.toStringAsFixed(2)}'),
              _buildDetailItem('Interest/Day', 'Rs ${interestPerDay.toStringAsFixed(2)}'),
              _buildDetailItem('Start Date', '${startDate.day}/${startDate.month}/${startDate.year}'),
              _buildDetailItem('Close Date', '${closeDate.day}/${closeDate.month}/${closeDate.year}'),
              _buildDetailItem('Days Used', '$daysUsed days'),
              _buildDetailItem('Total Interest', 'Rs ${totalInterest.toStringAsFixed(2)}'),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: AppColors.goldLight),
          const SizedBox(height: 16),
          
          // Total Payable
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payable:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkBrown,
                ),
              ),
              Text(
                'Rs ${totalPayable.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showLoanStatement(loan),
                  icon: const Icon(Icons.description, size: 18),
                  label: const Text('Statement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showLoanSummary(loan),
                  icon: const Icon(Icons.summarize, size: 18),
                  label: const Text('Summary'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.goldDark,
                    side: const BorderSide(color: AppColors.goldDark),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkGrayText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDarkBrown,
          ),
        ),
      ],
    );
  }

  void _showLoanStatement(Map<String, dynamic> loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Loan Statement #${loan['id']}'),
        content: const Text('Detailed loan statement would be displayed here with all transaction history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLoanSummary(Map<String, dynamic> loan) {
    final loanAmount = loan['amount'] as double;
    final startDate = loan['startDate'] as DateTime;
    final closeDate = loan['closeDate'] as DateTime;
    
    final interestPerDay = _calculateInterestPerDay(loanAmount);
    final daysUsed = _calculateDaysUsed(startDate, closeDate);
    final totalInterest = _calculateTotalInterest(loanAmount, daysUsed);
    final totalPayable = _calculateTotalPayable(loanAmount, totalInterest);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Loan Summary #${loan['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loan Amount: Rs ${loanAmount.toStringAsFixed(2)}'),
            Text('Interest per Day: Rs ${interestPerDay.toStringAsFixed(2)}'),
            Text('Days Used: $daysUsed'),
            Text('Total Interest: Rs ${totalInterest.toStringAsFixed(2)}'),
            const Divider(),
            Text(
              'Total Payable: Rs ${totalPayable.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loans'),
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
        child: _loans.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 64,
                      color: AppColors.goldLight,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No loans found',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.darkGrayText,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _loans.length,
                itemBuilder: (context, index) => _buildLoanCard(_loans[index]),
              ),
      ),
    );
  }
}