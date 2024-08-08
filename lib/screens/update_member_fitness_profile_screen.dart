import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/background.dart';
import '../widgets/animated_inkwell.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_modal.dart';

class UpdateMemberFitnessProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  const UpdateMemberFitnessProfileScreen({Key? key, required this.userInfo}) : super(key: key);

  @override
  _UpdateMemberFitnessProfileScreenState createState() => _UpdateMemberFitnessProfileScreenState();
}

class _UpdateMemberFitnessProfileScreenState extends State<UpdateMemberFitnessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _workoutLevel;
  late int _workoutFrequency;
  late int _workoutGoal;

  final Map<int, String> _workoutGoals = {
    1: 'Weight Loss',
    2: 'Muscle Building',
    3: 'Endurance Improvement'
  };

  final Map<int, String> _workoutLevels = {
    1: 'Beginner',
    2: 'Intermediate',
    3: 'Advanced'
  };

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
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: const CustomBackButton(),
                    title: Text(
                      'Update Fitness Profile',
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
          _buildFitnessProfileCard(),
          const SizedBox(height: 24),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildFitnessProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitness Profile',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildHeroDropdown(
              'Workout Goal',
              _workoutGoal,
              (value) {
                if (value != null) {
                  setState(() => _workoutGoal = value);
                }
              },
              _workoutGoals,
              'Choose your primary fitness goal',
            ),
            _buildHeroDropdown(
              'Workout Level',
              _workoutLevel,
              (value) {
                if (value != null) {
                  setState(() => _workoutLevel = value);
                }
              },
              _workoutLevels,
              'Select based on your current fitness level and experience',
            ),
            _buildWorkoutFrequencySlider(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroDropdown(String label, int value, Function(int?) onChanged, Map<int, String> items, String helperText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(helperText, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Hero(
            tag: label,
            child: Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: value,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: GoogleFonts.lato(color: Colors.black),
                    onChanged: onChanged,
                    items: items.entries.map<DropdownMenuItem<int>>((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutFrequencySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workout Frequency', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('How many times per week do you plan to work out?', style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.green[700],
            inactiveTrackColor: Colors.green[100],
            trackShape: const RoundedRectSliderTrackShape(),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            thumbColor: Colors.greenAccent,
            overlayColor: Colors.green.withAlpha(50),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
            tickMarkShape: const RoundSliderTickMarkShape(),
            activeTickMarkColor: Colors.green[700],
            inactiveTickMarkColor: Colors.green[100],
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: Colors.greenAccent,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
          child: Slider(
            value: _workoutFrequency.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: _workoutFrequency.toString(),
            onChanged: (value) {
              setState(() {
                _workoutFrequency = value.round();
              });
            },
          ),
        ),
        Text('$_workoutFrequency times per week', style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return AnimatedInkWell(
      onTap: _updateFitnessProfile,
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
            'Update Fitness Profile',
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

  void _updateFitnessProfile() async {
    if (_formKey.currentState!.validate()) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      try {
        await apiService.updateMember({
          'workout_level': _workoutLevel,
          'workout_frequency': _workoutFrequency,
          'workout_goal': _workoutGoal,
        });
        
        _showSuccessDialog('Fitness profile updated successfully');
      } catch (e) {
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