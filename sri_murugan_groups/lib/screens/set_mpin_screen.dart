import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class SetMpinScreen extends StatefulWidget {
  const SetMpinScreen({super.key});

  @override
  State<SetMpinScreen> createState() => _SetMpinScreenState();
}

class _SetMpinScreenState extends State<SetMpinScreen> {
  final List<TextEditingController> _mpinControllers = List.generate(4, (index) => TextEditingController());
  final List<TextEditingController> _confirmControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _mpinFocusNodes = List.generate(4, (index) => FocusNode());
  final List<FocusNode> _confirmFocusNodes = List.generate(4, (index) => FocusNode());
  bool _isLoading = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    for (var controller in _mpinControllers) {
      controller.dispose();
    }
    for (var controller in _confirmControllers) {
      controller.dispose();
    }
    for (var node in _mpinFocusNodes) {
      node.dispose();
    }
    for (var node in _confirmFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _mpin => _mpinControllers.map((c) => c.text).join();
  String get _confirmMpin => _confirmControllers.map((c) => c.text).join();

  void _onMpinChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _mpinFocusNodes[index + 1].requestFocus();
    }
    if (_mpin.length == 4) {
      setState(() {
        _showConfirm = true;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _confirmFocusNodes[0].requestFocus();
      });
    }
  }

  void _onConfirmChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _confirmFocusNodes[index + 1].requestFocus();
    }
    if (_confirmMpin.length == 4) {
      _setMpin();
    }
  }

  void _onBackspace(int index, List<TextEditingController> controllers, List<FocusNode> focusNodes) {
    if (controllers[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _setMpin() async {
    if (_mpin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 4-digit MPIN')),
      );
      return;
    }

    if (!_showConfirm) {
      setState(() {
        _showConfirm = true;
      });
      _confirmFocusNodes[0].requestFocus();
      return;
    }

    if (_mpin != _confirmMpin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MPIN does not match. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      // Clear confirm fields
      for (var controller in _confirmControllers) {
        controller.clear();
      }
      setState(() {
        _showConfirm = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await StorageService.setEncryptedString(StorageService.keyMpin, _mpin);
      await StorageService.setBool(StorageService.keyIsMpinSet, true);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set MPIN. Please try again.')),
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

  Widget _buildMpinField(int index, List<TextEditingController> controllers, List<FocusNode> focusNodes, Function(int, String) onChanged) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controllers[index].text.isNotEmpty ? AppColors.goldPrimary : AppColors.goldLight,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: true,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkBrown,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => onChanged(index, value),
        onTap: () {
          controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: controllers[index].text.length),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _showConfirm ? 'Confirm Your MPIN' : 'Set Your MPIN',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _showConfirm 
                      ? 'Please re-enter your 4-digit MPIN to confirm'
                      : 'Create a 4-digit MPIN for secure access',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textDarkBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                // MPIN Input Fields
                if (!_showConfirm) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => _buildMpinField(index, _mpinControllers, _mpinFocusNodes, _onMpinChanged),
                    ),
                  ),
                ],
                // Confirm MPIN Input Fields
                if (_showConfirm) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => _buildMpinField(index, _confirmControllers, _confirmFocusNodes, _onConfirmChanged),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldDark),
                      ),
                    ),
                ],
                const Spacer(),
                if (_showConfirm && !_isLoading) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showConfirm = false;
                        for (var controller in _confirmControllers) {
                          controller.clear();
                        }
                      });
                      _mpinFocusNodes[0].requestFocus();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldLight,
                      foregroundColor: AppColors.textDarkBrown,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back to Set MPIN',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}