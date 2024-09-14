import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../services/auth_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_modal.dart';
import '../widgets/background.dart';
import '../widgets/custom_button.dart';

class UpdateTrainerPersonalInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  const UpdateTrainerPersonalInfoScreen({
    super.key,
    required this.userInfo,
  });

  @override
  _UpdateTrainerPersonalInfoScreenState createState() => _UpdateTrainerPersonalInfoScreenState();
}

class _UpdateTrainerPersonalInfoScreenState extends State<UpdateTrainerPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _specializationController;
  late TextEditingController _experienceController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.userInfo?['first_name']);
    _lastNameController = TextEditingController(text: widget.userInfo?['last_name']);
    _specializationController = TextEditingController(text: widget.userInfo?['specialization']);
    _experienceController = TextEditingController(text: widget.userInfo?['experience']?.toString());
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
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
            colors: const [Color(0xFF6EB6FF), Colors.white],
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
                          const SizedBox(height: 16),
                          _buildPasswordSection(),
                          const SizedBox(height: 24),
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
          label: 'Specialization',
          controller: _specializationController,
          icon: Icons.school,
        ),
        CustomTextFormField(
          label: 'Years of Experience',
          controller: _experienceController,
          icon: Icons.work,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return CustomCard(
      title: 'Change Password',
      titleColor: Colors.black,
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
      backgroundColor: const Color(0xFF6EB6FF),
      textColor: Colors.white,
    );
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        _validateInputFields();

        await apiService.updateTrainer({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'specialization': _specializationController.text,
          'experience': int.parse(_experienceController.text),
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
    if (_specializationController.text.isEmpty) {
      throw Exception('Please enter your specialization');
    }
    if (_experienceController.text.isEmpty || int.tryParse(_experienceController.text) == null) {
      throw Exception('Please enter a valid number of years of experience');
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