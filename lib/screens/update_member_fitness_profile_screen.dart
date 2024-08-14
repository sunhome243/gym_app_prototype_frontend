import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_modal.dart';
import '../widgets/custom_dropdown.dart';

class UpdateMemberFitnessProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  const UpdateMemberFitnessProfileScreen({super.key, required this.userInfo});

  @override
  _UpdateMemberFitnessProfileScreenState createState() => _UpdateMemberFitnessProfileScreenState();
}

class _UpdateMemberFitnessProfileScreenState extends State<UpdateMemberFitnessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _workoutLevel;
  late int _workoutFrequency;
  late int _workoutGoal;

  @override
  void initState() {
    super.initState();
    _workoutLevel = widget.userInfo?['workout_level'] ?? 1;
    _workoutFrequency = widget.userInfo?['workout_frequency'] ?? 1;
    _workoutGoal = widget.userInfo?['workout_goal'] ?? 1;
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
                    padding: const EdgeInsets.fromLTRB(16, 3, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'Update Fitness Profile',
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
                          _buildFitnessProfileCard(),
                          const SizedBox(height: 20),
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

  Widget _buildFitnessProfileCard() {
    return CustomCard(
      title: 'Fitness Profile',
      titleColor: Colors.black,
      titleFontSize: 22,
      children: [
        CustomDropdown(
          label: 'Workout Goal',
          value: _workoutGoal,
          onChanged: (value) {
            if (value != null) {
              setState(() => _workoutGoal = value);
            }
          },
          items: const {
            1: {'label': 'Weight Loss', 'icon': Icons.trending_down},
            2: {'label': 'Muscle Building', 'icon': Icons.fitness_center},
            3: {'label': 'Endurance Improvement', 'icon': Icons.timer},
          },
          helperText: 'Choose your primary fitness goal',
        ),
        CustomDropdown(
          label: 'Workout Level',
          value: _workoutLevel,
          onChanged: (value) {
            if (value != null) {
              setState(() => _workoutLevel = value);
            }
          },
          items: const {
            1: {'label': 'Beginner', 'icon': Icons.accessibility_new},
            2: {'label': 'Intermediate', 'icon': Icons.directions_run},
            3: {'label': 'Advanced', 'icon': Icons.whatshot},
          },
          helperText: 'Select based on your current fitness level and experience',
        ),
        _buildWorkoutFrequencySelector(),
      ],
    );
  }

Widget _buildWorkoutFrequencySelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Workout Frequency',
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'How many times per week do you plan to work out?',
        style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
      ),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final day = index + 1;
          final isSelected = _workoutFrequency == day;
          return GestureDetector(
            onTap: () {
              setState(() {
                _workoutFrequency = day;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3CD687) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3CD687) : Colors.grey[300]!,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3CD687).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 24),
      Center(
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.lato(
              fontSize: 18,
              color: Colors.grey[800],
            ),
            children: [
              TextSpan(
                text: '$_workoutFrequency ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3CD687),
                ),
              ),
              TextSpan(
                text: _workoutFrequency == 1 ? 'day' : 'days',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' per week'),
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildUpdateButton() {
    return CustomUpdateButton(
      onPressed: _updateFitnessProfile,
      text: 'Update Fitness Profile',
      backgroundColor: const Color(0xFF3CD687),
      textColor: Colors.white,
    );
  }

  void _updateFitnessProfile() async {
    if (_formKey.currentState!.validate()) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      try {
        await apiService.updateMember({
          'workout_level': _workoutLevel,
          'workout_frequency': _workoutFrequency,
          'workout_goal': _workoutGoal,
        });

        if (!mounted) return;
        _showSuccessDialog('Fitness profile updated successfully');
      } catch (e) {
        if (!mounted) return;
        _showErrorDialog('Failed to update fitness profile', _getErrorMessage(e));
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
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
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            Navigator.of(context).pop(); // Return to the previous screen
          },
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