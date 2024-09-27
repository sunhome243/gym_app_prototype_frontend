import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../widgets/animated_inkwell.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/background.dart';
import '../../services/api_services.dart';
import '../../services/schemas.dart';
import '../add_workout_screen.dart';
import 'workout_execution_screen.dart';

class CustomWorkoutInitScreen extends StatefulWidget {
  final ApiService apiService;
  final int workoutType;
  final String? memberUid;
  final String? memberName;
  final Function refreshRecentSessions;  

  const CustomWorkoutInitScreen({
    super.key,
    required this.apiService,
    required this.workoutType,
    required this.refreshRecentSessions, 
    this.memberUid,
    this.memberName,
  });

  @override
  _CustomWorkoutInitScreenState createState() =>
      _CustomWorkoutInitScreenState();
}

class _CustomWorkoutInitScreenState extends State<CustomWorkoutInitScreen> {
  List<WorkoutInfo> _sessionPlan = [];
  final Set<String> _removingItems = {};
  bool _isNavigating = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(
            height: MediaQuery.of(context).size.height,
            colors: const [Color(0xFF6F42C1), Colors.white],
            stops: const [0.0, 0.3],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            heroTag: 'background_top',
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      const CustomBackButton(),
                      const SizedBox(width: 8),
                      Text(
                        'Create Workout',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Scrollbar(
                    thickness: 6,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildReviewSessionPlan(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildCreateSessionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSessionPlan() {
    return CustomCard(
      title: 'Review Session Plan',
      titleColor: Colors.black,
      titleFontSize: 21,
      trailing: IconButton(
        icon: const Icon(Icons.add, color: Color(0xFF6F42C1)),
        onPressed: _navigateToAddWorkout,
        tooltip: 'Add workout',
      ),
      children: [
        if (_sessionPlan.isEmpty)
          _buildEmptyState()
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sessionPlan.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final WorkoutInfo item = _sessionPlan.removeAt(oldIndex);
                _sessionPlan.insert(newIndex, item);
              });
              HapticFeedback.mediumImpact();
            },
            itemBuilder: (context, index) {
              final workout = _sessionPlan[index];
              return _buildWorkoutItem(workout, index);
            },
          ),
      ],
    );
  }

  Widget _buildWorkoutItem(WorkoutInfo workout, int index) {
    final isRemoving = _removingItems.contains(workout.workout_key.toString());
    return AnimatedContainer(
      key: ValueKey(workout.workout_key),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
          isRemoving ? -MediaQuery.of(context).size.width : 0, 0, 0),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.drag_handle, color: Colors.grey[400], size: 24),
            title: Text(
              workout.workout_name,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              workout.workout_part,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.red, size: 24),
              onPressed: () => _removeWorkout(workout),
              tooltip: 'Remove workout',
            ),
          ),
          if (index < _sessionPlan.length - 1) const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No workouts added yet',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add workouts',
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateSessionButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedInkWell(
        onTap: (_sessionPlan.isNotEmpty && !_isNavigating)
            ? () => _debounceNavigateToWorkoutExecution()
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: (_sessionPlan.isNotEmpty && !_isNavigating)
                ? const Color(0xFF6F42C1)
                : Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _isNavigating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Start Workout',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void _navigateToAddWorkout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWorkoutScreen(
          apiService: widget.apiService,
          initialSessionPlan: _sessionPlan,
          workoutType: widget.workoutType,
        ),
      ),
    );
    if (result != null && result is List<WorkoutInfo>) {
      setState(() {
        _sessionPlan = result;
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _removeWorkout(WorkoutInfo workout) {
    setState(() {
      _removingItems.add(workout.workout_key.toString());
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _sessionPlan
            .removeWhere((item) => item.workout_key == workout.workout_key);
        _removingItems.remove(workout.workout_key.toString());
      });
    });
    HapticFeedback.lightImpact();
  }

  void _debounceNavigateToWorkoutExecution() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _navigateToWorkoutExecution();
    });
  }

  Future<void> _navigateToWorkoutExecution() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WorkoutExecutionScreen(
            sessionPlan: _sessionPlan,
            workoutType: widget.workoutType,
            apiService: widget.apiService,
            memberUid: widget.memberUid,
            refreshRecentSessions: widget.refreshRecentSessions,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating to WorkoutExecutionScreen: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start workout: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }
}
