import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';

class ChangeMpinScreen extends StatefulWidget {
  const ChangeMpinScreen({super.key});

  @override
  State<ChangeMpinScreen> createState() => _ChangeMpinScreenState();
}

class _ChangeMpinScreenState extends State<ChangeMpinScreen> {
  final List<TextEditingController> _currentControllers = List.generate(4, (index) => TextEditingController());
  final List<TextEditingController> _newControllers = List.generate(4, (index) => TextEditingController());
  final List<TextEditingController> _confirmControllers = List.generate(4, (index) => TextEditingController());
  
  final List<FocusNode> _currentFocusNodes = List.generate(4, (index) => FocusNode());
  final List<FocusNode> _newFocusNodes = List.generate(4, (index) => FocusNode());
  final List<FocusNode> _confirmFocusNodes = List.generate(4, (index) => FocusNode());
  
  bool _isLoading = false;
  int _currentStep = 0; // 0: current, 1: new, 2: confirm

  @override
  void dispose() {
    for (var controller in _currentControllers) {
      controller.dispose();
    }
    for (var controller in _newControllers) {
      controller.dispose();
    }
    for (var controller in _confirmControllers) {
      controller.dispose();
    }
    for (var node in _currentFocusNodes) {
      node.dispose();
    }
    for (var node in _newFocusNodes) {
      node.dispose();
    }
    for (var node in _confirmFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _currentMpin => _currentControllers.map((c) => c.text).join();
  String get _newMpin => _newControllers.map((c) => c.text).join();
  String get _confirmMpin => _confirmControllers.map((c) => c.text).join();

  void _onCurrentChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _currentFocusNodes[index + 1].requestFocus();
    }
    if (_currentMpin.length == 4) {
      _verifyCurrentMpin();
    }
  }

  void _onNewChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _newFocusNodes[index + 1].requestFocus();
    }
    if (_newMpin.length == 4) {
      setState(() {
        _currentStep = 2;
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
      _changeMpin();
    }
  }

  Future<void> _verifyCurrentMpin() async {
    if (_currentMpin.length != 4) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await StorageService.verifyEncryptedString(
        StorageService.keyMpin,
        _currentMpin,
      );

      if (isValid) {
        setState(() {
          _currentStep = 1;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          _newFocusNodes[0].requestFocus();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current MPIN is incorrect'),
              backgroundColor: Colors.red,
            ),
          );
          // Clear current fields
          for (var controller in _currentControllers) {
            controller.clear();
          }
          _currentFocusNodes[0].requestFocus();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification failed. Please try again.'),
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

  Future<void> _changeMpin() async {
    if (_newMpin.length != 4 || _confirmMpin.length != 4) return;

    if (_newMpin != _confirmMpin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New MPIN does not match. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      // Clear confirm fields
      for (var controller in _confirmControllers) {
        controller.clear();
      }
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (_newMpin == _currentMpin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New MPIN must be different from current MPIN'),
          backgroundColor: Colors.red,
        ),
      );
      // Clear new and confirm fields
      for (var controller in _newControllers) {
        controller.clear();
      }
      for (var controller in _confirmControllers) {
        controller.clear();
      }
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await StorageService.setEncryptedString(StorageService.keyMpin, _newMpin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MPIN changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change MPIN. Please try again.'),
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

  String get _stepTitle {
    switch (_currentStep) {
      case 0:
        return 'Enter Current MPIN';
      case 1:
        return 'Enter New MPIN';
      case 2:
        return 'Confirm New MPIN';
      default:
        return '';
    }
  }

  String get _stepDescription {
    switch (_currentStep) {
      case 0:
        return 'Please enter your current 4-digit MPIN';
      case 1:
        return 'Create a new 4-digit MPIN';
      case 2:
        return 'Re-enter your new MPIN to confirm';
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (index) => _buildMpinField(index, _currentControllers, _currentFocusNodes, _onCurrentChanged),
          ),
        );
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (index) => _buildMpinField(index, _newControllers, _newFocusNodes, _onNewChanged),
          ),
        );
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (index) => _buildMpinField(index, _confirmControllers, _confirmFocusNodes, _onConfirmChanged),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change MPIN'),
        backgroundColor: AppColors.goldPrimary,
        foregroundColor: AppColors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryYellowTop, AppColors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isActive = index <= _currentStep;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.goldPrimary : AppColors.goldLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                
                // Step Title
                Text(
                  _stepTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Step Description
                Text(
                  _stepDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.darkGrayText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                
                // MPIN Input Fields
                _buildCurrentStep(),
                const SizedBox(height: 30),
                
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldDark),
                    ),
                  ),
                
                const Spacer(),
                
                // Back Button (only show for step 1 and 2)
                if (_currentStep > 0 && !_isLoading) ...[
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        if (_currentStep == 2) {
                          // Clear confirm fields and go back to new MPIN
                          for (var controller in _confirmControllers) {
                            controller.clear();
                          }
                          _currentStep = 1;
                          _newFocusNodes[0].requestFocus();
                        } else if (_currentStep == 1) {
                          // Clear new fields and go back to current MPIN
                          for (var controller in _newControllers) {
                            controller.clear();
                          }
                          _currentStep = 0;
                          _currentFocusNodes[0].requestFocus();
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.goldDark,
                      side: const BorderSide(color: AppColors.goldDark),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Back to New MPIN' : 'Back to Current MPIN',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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