import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/animated_inkwell.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/background.dart';
import '../../services/api_services.dart';
import '../../services/schemas.dart';
import 'trainer_personal_training_add_workout_screen.dart';
import 'trainer_personal_training_execution_screen.dart';

class TrainerPersonalTrainingInitScreen extends StatefulWidget {
  final ApiService apiService;
  final String memberUid;
  final String memberName;
  final String trainerUid;

  const TrainerPersonalTrainingInitScreen({
    super.key,
    required this.apiService,
    required this.memberUid,
    required this.memberName,
    required this.trainerUid,
  });

  @override
  _TrainerPersonalTrainingInitScreenState createState() =>
      _TrainerPersonalTrainingInitScreenState();
}

class _TrainerPersonalTrainingInitScreenState
    extends State<TrainerPersonalTrainingInitScreen> {
  List<WorkoutInfo> _sessionPlan = [];
  final Set<String> _removingItems = {};
  bool _isCreatingSession = false; // 추가: 세션 생성 중 상태

  final Color _themeColor = const Color(0xFF6EB6FF);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
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
                              'Create Personal Training',
                              style: GoogleFonts.lato(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'For ${widget.memberName}',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
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
                _buildStartTrainingButton(),
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
        icon: const Icon(Icons.add, color: Color(0xFF6EB6FF)),
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

  Widget _buildStartTrainingButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedInkWell(
        onTap: (_sessionPlan.isNotEmpty && !_isCreatingSession)
            ? _navigateToExecutionScreen
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: (_sessionPlan.isNotEmpty && !_isCreatingSession)
                ? _themeColor
                : Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _isCreatingSession
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Start Training',
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
        builder: (context) => TrainerPersonalTrainingAddWorkoutScreen(
          apiService: widget.apiService,
          initialSessionPlan: _sessionPlan,
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

  void _navigateToExecutionScreen() async {
    if (_isCreatingSession) return; // 이미 처리 중이면 무시

    setState(() {
      _isCreatingSession = true;
    });

    try {
      final sessionIDMap = await widget.apiService.createSession(
        3, // Personal training session type
        memberUid: widget.memberUid,
      );

      if (!mounted) return; // 위젯이 여전히 트리에 있는지 확인

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainerPersonalTrainingExecutionScreen(
            sessionPlan: _sessionPlan,
            apiService: widget.apiService,
            sessionIDMap: sessionIDMap,
            trainerUid: widget.trainerUid,
            memberUid: widget.memberUid,
            memberName: widget.memberName,
          ),
        ),
      );
    } catch (e) {
      print('Error creating session: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create session: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingSession = false;
        });
      }
    }
  }
}
