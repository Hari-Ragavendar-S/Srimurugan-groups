import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  double _currentLimit = 20000.0;
  double _requestedAmount = 20000.0;
  int _selectedDays = 15;
  bool _isApplicationSubmitted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final isRequested = await StorageService.getBool(StorageService.keyAdjustmentRequested);
    setState(() {
      _isApplicationSubmitted = isRequested;
    });
  }

  double get _newLimit => _requestedAmount;
  
  String get _tenureReminder {
    return '$_selectedDays days';
  }

  double get _interestImpact {
    return (_requestedAmount / 10000) * 15; // 15 per day for every 10,000
  }

  double get _totalInterest {
    return _interestImpact * _selectedDays;
  }

  double get _totalPayable {
    return _requestedAmount + _totalInterest;
  }

  Future<void> _applyNow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await StorageService.setBool(StorageService.keyAdjustmentRequested, true);
      
      setState(() {
        _isApplicationSubmitted = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit application. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildApplicationUnderProcess() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 50,
                  color: AppColors.goldPrimary,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Application Under Process',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkBrown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your loan application has been submitted and is currently being reviewed. You will be notified once the process is complete.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textDarkBrown,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanApplicationForm() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryYellowTop, AppColors.white],
          stops: [0.0, 0.4],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Apply for Loan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkBrown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your desired loan amount and tenure',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGrayText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Current Limit Card
              Container(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Limit:',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGrayText,
                      ),
                    ),
                    Text(
                      'Rs ${_currentLimit.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Loan Amount Slider Section
              Container(
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
                    const Text(
                      'Loan Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkBrown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Amount Display
                    Center(
                      child: Text(
                        'Rs ${_requestedAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.goldPrimary,
                        inactiveTrackColor: AppColors.primaryYellowTop,
                        thumbColor: AppColors.goldLight,
                        overlayColor: AppColors.goldPrimary.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _requestedAmount,
                        min: 0,
                        max: 40000,
                        divisions: 40,
                        onChanged: (value) {
                          setState(() {
                            _requestedAmount = value;
                          });
                        },
                      ),
                    ),
                    
                    // Min/Max Labels
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs 0',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrayText,
                          ),
                        ),
                        Text(
                          'Rs 40,000',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrayText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Days Selection Section
              Container(
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
                    const Text(
                      'Loan Tenure (Days):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkBrown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Days Display
                    Center(
                      child: Text(
                        '$_selectedDays Days',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Days Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.goldPrimary,
                        inactiveTrackColor: AppColors.primaryYellowTop,
                        thumbColor: AppColors.goldLight,
                        overlayColor: AppColors.goldPrimary.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _selectedDays.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        onChanged: (value) {
                          setState(() {
                            _selectedDays = value.round();
                          });
                        },
                      ),
                    ),
                    
                    // Min/Max Labels
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 Day',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrayText,
                          ),
                        ),
                        Text(
                          '30 Days',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrayText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Calculation Details Cards
              Container(
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
                  children: [
                    _buildDetailRow('Loan Amount:', 'Rs ${_requestedAmount.toStringAsFixed(0)}'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Tenure:', '$_selectedDays days'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Interest/Day:', 'Rs ${_interestImpact.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Total Interest:', 'Rs ${_totalInterest.toStringAsFixed(2)}'),
                    const Divider(height: 24, color: AppColors.goldLight),
                    _buildDetailRow('Total Payable:', 'Rs ${_totalPayable.toStringAsFixed(2)}', isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Apply Button
              ElevatedButton(
                onPressed: _isLoading ? null : _applyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      )
                    : const Text(
                        'Apply for Loan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textDarkBrown : AppColors.darkGrayText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.goldDark : AppColors.textDarkBrown,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isApplicationSubmitted
          ? null
          : AppBar(
              title: const Text('Apply for Loan'),
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.white,
            ),
      body: _isApplicationSubmitted
          ? _buildApplicationUnderProcess()
          : _buildLoanApplicationForm(),
    );
  }
}