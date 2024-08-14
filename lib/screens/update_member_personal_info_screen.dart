import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../services/auth_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/background.dart'; 
import '../widgets/custom_button.dart';

class UpdateMemberPersonalInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? userInfo;
  final bool useMetric;

  const UpdateMemberPersonalInfoScreen({
    super.key,
    required this.userInfo,
    required this.useMetric,
  });

  @override
  _UpdateMemberPersonalInfoScreenState createState() => _UpdateMemberPersonalInfoScreenState();
}

class _UpdateMemberPersonalInfoScreenState extends State<UpdateMemberPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _useMetric = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.userInfo?['first_name']);
    _lastNameController = TextEditingController(text: widget.userInfo?['last_name']);
    _ageController = TextEditingController(text: widget.userInfo?['age']?.toString() ?? '');
    _heightController = TextEditingController(text: widget.userInfo?['height']?.toString() ?? '');
    _weightController = TextEditingController(text: widget.userInfo?['weight']?.toString() ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _useMetric = widget.useMetric;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(
            height: MediaQuery.of(context).size.height,
            colors: const [Color(0xFF3CD687), Colors.white],
            stops: const [0.0, 0.3],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            heroTag: 'background_top',
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'Update Personal Info',
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPersonalInfoSection(),
                          const SizedBox(height: 5),
                          _buildPasswordSection(),
                          const SizedBox(height: 5),
                          _buildUpdateButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildPersonalInfoSection() {
    return CustomCard(
      title: 'Personal Information',
      titleColor: Colors.black,
      titleFontSize: 22,
      children: [
        CustomTextFormField(
          label: 'First Name',
          controller: _firstNameController,
          icon: Icons.person,
        ),
        CustomTextFormField(
          label: 'Last Name',
          controller: _lastNameController,
          icon: Icons.person,
        ),
        CustomTextFormField(
          label: 'Age',
          controller: _ageController,
          icon: Icons.cake,
          keyboardType: TextInputType.number,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                label: 'Height (${_useMetric ? 'cm' : 'in'})',
                controller: _heightController,
                icon: Icons.height,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomTextFormField(
                label: 'Weight (${_useMetric ? 'kg' : 'lbs'})',
                controller: _weightController,
                icon: Icons.fitness_center,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildUnitToggle(),
      ],
    );
  }

  Widget _buildUnitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Unit System',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        CupertinoSlidingSegmentedControl<bool>(
          groupValue: _useMetric,
          backgroundColor: Colors.grey[200]!,
          thumbColor: const Color(0xFF3CD687),
          children: {
            true: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Metric',
                style: GoogleFonts.lato(
                  color: _useMetric ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            false: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Imperial',
                style: GoogleFonts.lato(
                  color: !_useMetric ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          },
          onValueChanged: (value) {
            if (value != null) {
              setState(() {
                _useMetric = value;
                _convertUnits();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return CustomCard(
      title: 'Change Password',
      titleColor: const Color.fromARGB(255, 0, 0, 0),
      titleFontSize: 22,
      children: [
        CustomTextFormField(
          label: 'Current Password',
          controller: _currentPasswordController,
          icon: Icons.lock,
          isPassword: true,
        ),
        CustomTextFormField(
          label: 'New Password',
          controller: _newPasswordController,
          icon: Icons.lock_open,
          isPassword: true,
        ),
        CustomTextFormField(
          label: 'Confirm New Password',
          controller: _confirmPasswordController,
          icon: Icons.lock_outline,
          isPassword: true,
        ),
      ],
    );
  }

 Widget _buildUpdateButton() {
  return CustomUpdateButton(
    onPressed: _updateProfile,
    text: 'Update Profile',
    backgroundColor: const Color(0xFF3CD687),
    textColor: Colors.white,
  );
}

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      await _savePreferredUnit(_useMetric);
      try {
        _validateInputFields();

        await apiService.updateMember({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'age': int.parse(_ageController.text),
          'height': double.parse(_heightController.text),
          'weight': double.parse(_weightController.text),
          'use_metric': _useMetric,
        });
        
        if (_currentPasswordController.text.isNotEmpty &&
            _newPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty) {
          if (_newPasswordController.text != _confirmPasswordController.text) {
            throw Exception('New passwords do not match');
          }
          await authService.changePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
          );
        }

        _showSuccessDialog('Profile updated successfully');
      } catch (e) {
        _showErrorDialog('Failed to update profile', _getErrorMessage(e));
      }
    }
  }

  void _validateInputFields() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      throw Exception('Name fields cannot be empty');
    }
    if (_ageController.text.isEmpty || int.tryParse(_ageController.text) == null) {
      throw Exception('Please enter a valid age');
    }
    if (_heightController.text.isEmpty || double.tryParse(_heightController.text) == null) {
      throw Exception('Please enter a valid height');
    }
    if (_weightController.text.isEmpty || double.tryParse(_weightController.text) == null) {
      throw Exception('Please enter a valid weight');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    if (error.toString().contains('FormatException')) {
      return 'Please check your input. Make sure all fields are filled correctly.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> _savePreferredUnit(bool useMetric) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useMetric', useMetric);
  }

  void _convertUnits() {
    if (_heightController.text.isNotEmpty) {
      double value = double.tryParse(_heightController.text) ?? 0;
      _heightController.text = _useMetric
          ? (value * 2.54).toStringAsFixed(1)  // inches to cm
          : (value / 2.54).toStringAsFixed(1); // cm to inches
    }
    if (_weightController.text.isNotEmpty) {
      double value = double.tryParse(_weightController.text) ?? 0;
      _weightController.text = _useMetric
          ? (value * 0.453592).toStringAsFixed(1)  // lbs to kg
          : (value / 0.453592).toStringAsFixed(1); // kg to lbs
    }
  }

  void _showSuccessDialog(String message) {
    showCustomModal(
      context: context,
      title: 'Success',
      theme: CustomModalTheme.green,
      icon: CupertinoIcons.check_mark_circled,
      content: Text(
        message,
        style: GoogleFonts.lato(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: [
        CustomModalAction(
          text: 'OK',
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void _showErrorDialog(String title, String message) {
    showCustomModal(
      context: context,
      title: title,
      theme: CustomModalTheme.red,
      icon: CupertinoIcons.exclamationmark_circle,
      content: Text(
        message,
        style: GoogleFonts.lato(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: [
        CustomModalAction(
          text: 'OK',
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}