import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/background.dart';
import '../../services/api_services.dart';
import '../../services/schemas.dart';
import '../add_workout_screen.dart';

class TrainerReviewSessionPlanScreen extends StatefulWidget {
  final List<WorkoutInfo> sessionPlan;
  final ApiService apiService;
  final int currentWorkoutIndex;
  final List<ExerciseSave> completedExercises;
  final String memberName;

  const TrainerReviewSessionPlanScreen({
    super.key,
    required this.sessionPlan,
    required this.apiService,
    required this.currentWorkoutIndex,
    required this.completedExercises,
    required this.memberName,
  });

  @override
  State<TrainerReviewSessionPlanScreen> createState() =>
      _TrainerReviewSessionPlanScreenState();
}

class _TrainerReviewSessionPlanScreenState
    extends State<TrainerReviewSessionPlanScreen> {
  late List<WorkoutInfo> _sessionPlan;
  bool _isLoading = false;
  bool _isSaving = false;
  final Set<String> _removingItems = {};
  late int _currentWorkoutIndex;

  Color get _themeColor => const Color(0xFF6EB6FF);

  @override
  void initState() {
    super.initState();
    _sessionPlan = List.from(widget.sessionPlan);
    _currentWorkoutIndex = widget.currentWorkoutIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(
            height: MediaQuery.of(context).size.height,
            colors: [_themeColor, Colors.white],
            stops: const [0.0, 0.3],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            heroTag: 'background_top',
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildSessionPlanList(),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child:
                  Center(child: CircularProgressIndicator(color: _themeColor)),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          const CustomBackButton(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Session Plan',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Training ${widget.memberName}',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _navigateToAddWorkout,
            tooltip: 'Add workout',
          ),
        ],
      ),
    );
  }

  Widget _buildSessionPlanList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessionPlan.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final WorkoutInfo item = _sessionPlan.removeAt(oldIndex);
          _sessionPlan.insert(newIndex, item);

          // Adjust currentWorkoutIndex if necessary
          if (_currentWorkoutIndex == oldIndex) {
            _currentWorkoutIndex = newIndex;
          } else if (oldIndex < _currentWorkoutIndex &&
              newIndex >= _currentWorkoutIndex) {
            _currentWorkoutIndex--;
          } else if (oldIndex > _currentWorkoutIndex &&
              newIndex <= _currentWorkoutIndex) {
            _currentWorkoutIndex++;
          }
        });
        HapticFeedback.mediumImpact();
      },
      itemBuilder: (context, index) {
        final workout = _sessionPlan[index];
        return _buildWorkoutItem(workout, index);
      },
    );
  }

  Widget _buildWorkoutItem(WorkoutInfo workout, int index) {
    final isCurrent = index == _currentWorkoutIndex;
    final isCompleted = index < _currentWorkoutIndex;
    final completedExercise = widget.completedExercises.firstWhere(
      (exercise) => exercise.workout_key == workout.workout_key,
      orElse: () => ExerciseSave(workout_key: workout.workout_key, sets: []),
    );
    final isRemoving = _removingItems.contains(workout.workout_key.toString());

    return AnimatedContainer(
      key: ValueKey(workout.workout_key),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
          isRemoving ? -MediaQuery.of(context).size.width : 0, 0, 0),
      child: Dismissible(
        key: ValueKey(workout.workout_key),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _removeWorkout(workout),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: _buildWorkoutStatusIcon(
                    isCurrent, isCompleted, completedExercise),
                title: Text(
                  workout.workout_name,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                trailing: Icon(Icons.drag_handle, color: Colors.grey[400]),
              ),
              _buildWorkoutProgress(workout, completedExercise),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutStatusIcon(
      bool isCurrent, bool isCompleted, ExerciseSave completedExercise) {
    if (isCurrent) {
      return Icon(Icons.play_arrow, color: _themeColor, size: 24);
    } else if (isCompleted &&
        completedExercise.sets.length ==
            _sessionPlan[_currentWorkoutIndex].workoutSets.length) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 24);
    } else {
      return const Icon(Icons.circle_outlined, color: Colors.grey, size: 24);
    }
  }

  Widget _buildWorkoutProgress(
      WorkoutInfo workout, ExerciseSave completedExercise) {
    final completedSets = completedExercise.sets.length;
    final totalSets = workout.workoutSets.length;
    final progress = totalSets > 0 ? (completedSets / totalSets) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress: $completedSets / $totalSets sets',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _themeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: _isSaving ? null : _saveAndReturn,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _isSaving ? Colors.grey : _themeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isSaving
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Text(
                  'Save and Return',
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

  Future<void> _navigateToAddWorkout() async {
    setState(() => _isLoading = true);
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddWorkoutScreen(
            apiService: widget.apiService,
            initialSessionPlan: _sessionPlan,
            workoutType: 4, // Custom workout type for personal training
          ),
        ),
      );
      if (mounted) {
        if (result != null && result is List<WorkoutInfo>) {
          setState(() {
            _sessionPlan = result;
          });
          HapticFeedback.mediumImpact();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load workouts: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeWorkout(WorkoutInfo workout) {
    setState(() {
      _removingItems.add(workout.workout_key.toString());
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _sessionPlan
              .removeWhere((item) => item.workout_key == workout.workout_key);
          _removingItems.remove(workout.workout_key.toString());

          // Adjust currentWorkoutIndex if necessary
          if (_currentWorkoutIndex >= _sessionPlan.length) {
            _currentWorkoutIndex = _sessionPlan.length - 1;
          }
        });
      }
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _saveAndReturn() async {
    setState(() => _isSaving = true);
    // Here you might want to add any save logic, e.g., API calls
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulating a save operation
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, _sessionPlan);
    }
  }
}
