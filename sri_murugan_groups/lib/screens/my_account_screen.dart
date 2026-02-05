import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/colors.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
import 'change_mpin_screen.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await StorageService.getString(StorageService.keyName);
    final email = await StorageService.getString(StorageService.keyEmail);
    final phone = await StorageService.getString(StorageService.keyPhone);
    final address = await StorageService.getString(StorageService.keyAddress);
    final profileImagePath = await StorageService.getString('local_profileImage');

    setState(() {
      _name = name;
      _email = email;
      _phone = phone;
      _address = address;
      _profileImagePath = profileImagePath.isEmpty ? null : profileImagePath;
    });
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.goldPrimary),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.goldPrimary),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        await StorageService.setString('local_profileImage', image.path);
        setState(() {
          _profileImagePath = image.path;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showPartnerDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Partner Details',
          style: TextStyle(
            color: AppColors.textDarkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPartnerCard(
                'Sri Murugan Groups',
                'Main Branch - Mangala Puram',
                '+60 12-345-6789',
                'srimurugan@groups.com',
                'Managing Director',
              ),
              const SizedBox(height: 16),
              _buildPartnerCard(
                'Rajesh Kumar',
                'Senior Partner',
                '+60 12-456-7890',
                'rajesh@srimurugan.com',
                'Business Development',
              ),
              const SizedBox(height: 16),
              _buildPartnerCard(
                'Priya Sharma',
                'Financial Partner',
                '+60 12-567-8901',
                'priya@srimurugan.com',
                'Finance & Operations',
              ),
              const SizedBox(height: 16),
              _buildPartnerCard(
                'Arun Patel',
                'Regional Partner',
                '+60 12-678-9012',
                'arun@srimurugan.com',
                'Regional Operations',
              ),
              const SizedBox(height: 16),
              _buildPartnerCard(
                'Meera Nair',
                'Customer Relations Partner',
                '+60 12-789-0123',
                'meera@srimurugan.com',
                'Customer Support',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.goldPrimary,
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(String name, String position, String phone, String email, String department) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.goldLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            position,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.goldDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: AppColors.darkGrayText),
              const SizedBox(width: 6),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGrayText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.email, size: 14, color: AppColors.darkGrayText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrayText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.work, size: 14, color: AppColors.darkGrayText),
              const SizedBox(width: 6),
              Text(
                department,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGrayText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
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
          // Profile Picture
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: AppColors.goldPrimary, width: 2),
                  ),
                  child: _profileImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(38),
                          child: Image.file(
                            File(_profileImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.goldPrimary,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.goldPrimary,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 12,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // User Info
          Text(
            _name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrayText,
            ),
          ),
          const SizedBox(height: 16),
          
          // Contact Info
          _buildInfoRow(Icons.phone, _phone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, _address),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.goldDark,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrayText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard() {
    return Container(
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
          _buildMenuItem(
            Icons.business,
            'Partner Details',
            _showPartnerDetails,
          ),
          const Divider(height: 1, color: AppColors.goldLight),
          _buildMenuItem(
            Icons.lock_outline,
            'Change Password',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
            ),
          ),
          const Divider(height: 1, color: AppColors.goldLight),
          _buildMenuItem(
            Icons.pin,
            'Change MPIN',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangeMpinScreen()),
            ),
          ),
          const Divider(height: 1, color: AppColors.goldLight),
          _buildMenuItem(
            Icons.logout,
            'Logout',
            _logout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDestructive ? Colors.red : AppColors.goldPrimary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : AppColors.goldPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red : AppColors.textDarkBrown,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDestructive ? Colors.red : AppColors.goldDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildMenuCard(),
              const SizedBox(height: 40),
              
              // App Info
              Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  children: [
                    Text(
                      'Sri Murugan Groups',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkBrown,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mangala Puram',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGrayText,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrayText,
                      ),
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
}