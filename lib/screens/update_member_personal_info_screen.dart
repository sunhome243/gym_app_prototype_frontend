import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../services/auth_service.dart';
import '../widgets/background.dart';
import '../widgets/animated_inkwell.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: const CustomBackButton(),
                    title: Text(
                      'Update Personal Info',
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildForm(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInfoCard(),
          const SizedBox(height: 24),
          _buildPasswordChangeCard(),
          const SizedBox(height: 24),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextFormField('First Name', _firstNameController),
            _buildTextFormField('Last Name', _lastNameController),
            _buildTextFormField('Age', _ageController, keyboardType: TextInputType.number),
            _buildMeasurementField('Height', _heightController, _useMetric ? 'cm' : 'in'),
            _buildMeasurementField('Weight', _weightController, _useMetric ? 'kg' : 'lbs'),
            _buildUnitToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Unit System', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
          CupertinoSlidingSegmentedControl<bool>(
            groupValue: _useMetric,
            children: const {
              true: Text('Metric'),
              false: Text('Imperial'),
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
      ),
    );
  }

  Widget _buildPasswordChangeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Password',
              style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextFormField('Current Password', _currentPasswordController, isPassword: true),
            _buildTextFormField('New Password', _newPasswordController, isPassword: true),
            _buildTextFormField('Confirm New Password', _confirmPasswordController, isPassword: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, {TextInputType? keyboardType, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: controller,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            placeholder: label,
            keyboardType: keyboardType,
            obscureText: isPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementField(String label, TextEditingController controller, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  placeholder: label,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Text(unit, style: GoogleFonts.lato(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return AnimatedInkWell(
      onTap: _updateProfile,
      splashColor: const Color(0xFF3CD687).withOpacity(0.3),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3CD687),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Update Profile',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      await _savePreferredUnit(_useMetric);
      try {
        // Validate input fields
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