import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/background.dart';
import '../../services/api_services.dart';
import '../../services/schemas.dart';
import 'dart:async';
import '../trainer_workout/trainer_review_session.dart';
import '../trainer_workout/trainer_workout_summary.dart';

class TrainerPersonalTrainingExecutionScreen extends StatefulWidget {
  final List<WorkoutInfo> sessionPlan;
  final ApiService apiService;
  final SessionIDMap sessionIDMap;
  final String trainerUid;
  final String memberUid;
  final String memberName;

  const TrainerPersonalTrainingExecutionScreen({
    super.key,
    required this.sessionPlan,
    required this.apiService,
    required this.sessionIDMap,
    required this.trainerUid,
    required this.memberUid,
    required this.memberName,
  });

  @override
  _TrainerPersonalTrainingExecutionScreenState createState() =>
      _TrainerPersonalTrainingExecutionScreenState();
}

class _TrainerPersonalTrainingExecutionScreenState
    extends State<TrainerPersonalTrainingExecutionScreen>
    with TickerProviderStateMixin {
  late List<WorkoutInfo> _sessionPlan;
  int _currentWorkoutIndex = 0;
  int _currentSet = 1;
  int _timer = 60;
  int _runningTimer = 0;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  Timer? _timerInstance;
  SessionIDMap? _currentSession;
  final List<ExerciseSave> _completedExercises = [];
  bool _isLoading = false;
  late AnimationController _setAnimationController;
  bool _hasShownSlideHint = false;
  final Map<int, AnimationController> _swipeControllers = {};

  Color get _themeColor => const Color(0xFF6EB6FF);

  @override
  void initState() {
    super.initState();
    _sessionPlan = List.from(widget.sessionPlan);
    _ensureDefaultSet();
    _createSession();
    _initializeTimer();
    _setAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeSwipeControllers();
  }

  @override
  void dispose() {
    _timerInstance?.cancel();
    _setAnimationController.dispose();
    for (var controller in _swipeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeSwipeControllers() {
    for (int i = 0;
        i < _sessionPlan[_currentWorkoutIndex].workoutSets.length;
        i++) {
      _swipeControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  void _ensureDefaultSet() {
    for (var workout in _sessionPlan) {
      if (workout.workoutSets.isEmpty) {
        workout.workoutSets.add(WorkoutSet(
          weight: 0.0,
          reps: 0,
          rest_time: 60,
        ));
      }
    }
  }

  void _initializeTimer() {
    if (_sessionPlan.isNotEmpty && _sessionPlan[0].workoutSets.isNotEmpty) {
      _timer = _sessionPlan[0].workoutSets[0].rest_time;
      _runningTimer = _timer;
    }
  }

  Future<void> _createSession() async {
    setState(() => _isLoading = true);
    try {
      _currentSession = widget.sessionIDMap;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to create session: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _startTimer() {
    _timerInstance?.cancel();
    _timerInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timer > 0) {
          _timer--;
          _runningTimer = _timer;
        } else {
          _isTimerRunning = false;
          _isTimerPaused = false;
          timer.cancel();
        }
      });
    });
  }

  void _toggleTimer() {
    setState(() {
      if (_isTimerRunning) {
        if (_isTimerPaused) {
          _startTimer();
          _isTimerPaused = false;
        } else {
          _timerInstance?.cancel();
          _isTimerPaused = true;
        }
      } else {
        _isTimerRunning = true;
        _startTimer();
      }
    });
  }

  void _nextSet() {
    HapticFeedback.mediumImpact();
    setState(() {
      final currentWorkout = _sessionPlan[_currentWorkoutIndex];
      final currentSet = currentWorkout.workoutSets[_currentSet - 1];

      _completedExercises.add(ExerciseSave(
        workout_key: currentWorkout.workout_key,
        sets: [
          SetSave(
            set_num: _currentSet,
            weight: currentSet.weight,
            reps: currentSet.reps,
            rest_time: currentSet.rest_time,
          )
        ],
      ));

      _runningTimer = currentSet.rest_time;
      _timer = _runningTimer;

      if (_currentSet < currentWorkout.workoutSets.length) {
        _currentSet++;
      } else if (_currentWorkoutIndex < _sessionPlan.length - 1) {
        _currentWorkoutIndex++;
        _currentSet = 1;
        _ensureDefaultSet();
      } else {
        _saveSession();
        return;
      }

      _isTimerRunning = true;
      _isTimerPaused = false;
      _startTimer();
      _setAnimationController.forward(from: 0.0);
    });
  }

  Future<void> _saveSession() async {
    setState(() => _isLoading = true);
    try {
      final sessionSave = SessionSave(
        session_id: _currentSession!.session_id,
        exercises: _completedExercises,
      );
      await widget.apiService.saveSession(sessionSave);
      setState(() => _isLoading = false);

      // Navigate to the WorkoutSummaryScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TrainerWorkoutSummaryScreen(
            completedExercises: _completedExercises,
            memberName: widget.memberName,
            onEndSession: () {
              // Navigate back to the home screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to save session: $e');
    }
  }

  void _openReviewSessionPlan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainerReviewSessionPlanScreen(
          sessionPlan: _sessionPlan,
          apiService: widget.apiService,
          currentWorkoutIndex: _currentWorkoutIndex,
          completedExercises: _completedExercises,
          memberName: widget.memberName,
        ),
      ),
    );
    if (result != null) {
      if (result is List<WorkoutInfo>) {
        setState(() {
          _sessionPlan = result;
          if (_currentWorkoutIndex >= _sessionPlan.length) {
            _currentWorkoutIndex = _sessionPlan.length - 1;
          }
          if (_currentSet >
              _sessionPlan[_currentWorkoutIndex].workoutSets.length) {
            _currentSet = _sessionPlan[_currentWorkoutIndex].workoutSets.length;
          }
          _initializeTimer();
          _initializeSwipeControllers();
        });
      } else if (result is int) {
        setState(() {
          _currentWorkoutIndex = result;
          _currentSet = 1;
          _initializeTimer();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkout =
        _sessionPlan.isNotEmpty ? _sessionPlan[_currentWorkoutIndex] : null;

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
                _buildAppBar(currentWorkout),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (currentWorkout != null) ...[
                          const SizedBox(height: 16),
                          _buildRecordCard(currentWorkout),
                          const SizedBox(height: 16),
                          _buildSetsCard(currentWorkout),
                        ] else
                          _buildNoWorkoutsMessage(),
                      ],
                    ),
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(WorkoutInfo? currentWorkout) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: _openReviewSessionPlan,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentWorkout?.workout_name ?? 'Workout',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }

  Widget _buildRecordCard(WorkoutInfo workout) {
    return CustomCard(
      title: 'Record',
      titleColor: Colors.black,
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'Graph placeholder',
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetsCard(WorkoutInfo workout) {
    return CustomCard(
      title: 'Sets',
      titleColor: Colors.black,
      children: [
        _buildSetHeader(),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: _buildSetsList(workout),
          ),
        ),
      ],
    );
  }

  Widget _buildSetHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(width: 60),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildHeaderItem('Weight')),
                Expanded(child: _buildHeaderItem('Reps')),
                Expanded(child: _buildHeaderItem('Rest')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  List<Widget> _buildSetsList(WorkoutInfo workout) {
    return List.generate(workout.workoutSets.length + 1, (index) {
      if (index == workout.workoutSets.length) {
        return _buildAddSetButton(workout);
      }

      final set = workout.workoutSets[index];
      final isCurrentSet = index + 1 == _currentSet;
      final isCompletedSet = index + 1 < _currentSet;

      return GestureDetector(
        onTap: () {
          if (!isCurrentSet) {
            HapticFeedback.selectionClick();
            setState(() {
              _currentSet = index + 1;
              _timer = set.rest_time;
              _runningTimer = _timer;
            });
          }
        },
        onHorizontalDragUpdate: (details) {
          if (!isCurrentSet && !isCompletedSet) {
            final newValue =
                _swipeControllers[index]!.value - details.delta.dx / 80.0;
            _swipeControllers[index]!.value = newValue.clamp(0.0, 1.0);
          }
        },
        onHorizontalDragEnd: (details) {
          if (!isCurrentSet && !isCompletedSet) {
            if (_swipeControllers[index]!.value > 0.5) {
              _swipeControllers[index]!.forward();
            } else {
              _swipeControllers[index]!.reverse();
            }
          }
        },
        child: AnimatedBuilder(
          animation: _swipeControllers[index]!,
          builder: (context, child) {
            return Stack(
              children: [
                if (!isCurrentSet && !isCompletedSet)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              workout.workoutSets.removeAt(index);
                              if (_currentSet > workout.workoutSets.length) {
                                _currentSet = workout.workoutSets.length;
                              }
                              _swipeControllers.remove(index);
                              _initializeSwipeControllers();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(
                      isCurrentSet || isCompletedSet
                          ? 0
                          : -80 * _swipeControllers[index]!.value,
                      0),
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color:
                          _getSetBackgroundColor(isCurrentSet, isCompletedSet),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getSetBorderColor(isCurrentSet, isCompletedSet),
                        width: isCurrentSet ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isCurrentSet)
                          BoxShadow(
                            color: _themeColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _getSetNumberBackgroundColor(
                                isCurrentSet, isCompletedSet),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getSetNumberColor(
                                  isCurrentSet, isCompletedSet),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                  child: _buildEditableField(
                                      set.weight.toString(), 'kg', (value) {
                                setState(() {
                                  workout.workoutSets[index] = set.copyWith(
                                      weight:
                                          double.tryParse(value) ?? set.weight);
                                });
                              }, isCompletedSet)),
                              Expanded(
                                  child: _buildEditableField(
                                      set.reps.toString(), 'reps', (value) {
                                setState(() {
                                  workout.workoutSets[index] = set.copyWith(
                                      reps: int.tryParse(value) ?? set.reps);
                                });
                              }, isCompletedSet)),
                              Expanded(
                                  child: _buildEditableField(
                                      set.rest_time.toString(), 's', (value) {
                                setState(() {
                                  workout.workoutSets[index] = set.copyWith(
                                      rest_time:
                                          int.tryParse(value) ?? set.rest_time);
                                });
                              }, isCompletedSet)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOut).slide(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 300.ms,
          curve: Curves.easeInOut);
    });
  }

  Widget _buildAddSetButton(WorkoutInfo workout) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              workout.workoutSets.add(WorkoutSet(
                weight: 0.0,
                reps: 0,
                rest_time: 60,
              ));
              _initializeSwipeControllers();
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.grey[600], size: 24),
              const SizedBox(width: 8),
              Text(
                'Add Set',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOut).slide(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
        duration: 300.ms,
        curve: Curves.easeInOut);
  }

  Widget _buildEditableField(
      String value, String unit, Function(String) onChanged, bool isCompleted) {
    return Center(
      child: IntrinsicWidth(
        child: TextFormField(
          initialValue: value,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isCompleted ? Colors.grey[600] : Colors.black87,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            suffixText: unit,
            suffixStyle: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            border: InputBorder.none,
          ),
          onChanged: onChanged,
          enabled: !isCompleted,
          onTap: () {
            if (!isCompleted) {
              final TextEditingController controller =
                  TextEditingController.fromValue(
                TextEditingValue(
                  text: value,
                  selection:
                      TextSelection(baseOffset: 0, extentOffset: value.length),
                ),
              );
              (context as Element).markNeedsBuild();
            }
          },
        ),
      ),
    );
  }

  Color _getSetBackgroundColor(bool isCurrentSet, bool isCompletedSet) {
    if (isCurrentSet) return _themeColor.withOpacity(0.1);
    if (isCompletedSet) return Colors.grey[200]!;
    return Colors.white;
  }

  Color _getSetBorderColor(bool isCurrentSet, bool isCompletedSet) {
    if (isCurrentSet) return _themeColor;
    if (isCompletedSet) return Colors.grey[400]!;
    return Colors.grey[300]!;
  }

  Color _getSetNumberBackgroundColor(bool isCurrentSet, bool isCompletedSet) {
    if (isCurrentSet) return _themeColor.withOpacity(0.2);
    if (isCompletedSet) return Colors.grey[300]!;
    return Colors.grey[100]!;
  }

  Color _getSetNumberColor(bool isCurrentSet, bool isCompletedSet) {
    if (isCurrentSet) return _themeColor;
    if (isCompletedSet) return Colors.grey[600]!;
    return Colors.black87;
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildTimerControl(),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _buildNextSetButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerControl() {
    final Color timerColor = _isTimerRunning
        ? (_timer > 30
            ? Colors.green
            : (_timer > 10 ? Colors.orange : Colors.red))
        : Colors.grey[400]!;

    return GestureDetector(
      onTap: _toggleTimer,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: timerColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isTimerRunning
                  ? (_isTimerPaused ? Icons.play_arrow : Icons.pause)
                  : Icons.timer,
              color: timerColor,
            ),
            const SizedBox(width: 8),
            Text(
              '$_timer s',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: timerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSetButton() {
    return ElevatedButton(
      onPressed: () {
        if (_isTimerRunning) {
          _timerInstance?.cancel();
          setState(() {
            _isTimerRunning = false;
            _isTimerPaused = false;
          });
        }
        _nextSet();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _themeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isLastSet ? 'Finish Workout' : 'Next Set',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            _isLastSet ? Icons.check_circle : Icons.arrow_forward,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  bool get _isLastSet =>
      _currentSet == _sessionPlan[_currentWorkoutIndex].workoutSets.length &&
      _currentWorkoutIndex == _sessionPlan.length - 1;

  Widget _buildNoWorkoutsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No workouts in the session plan.',
          style: GoogleFonts.lato(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasShownSlideHint) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSlideToDeleteHint();
      });
    }
  }

  void _showSlideToDeleteHint() {
    if (_sessionPlan.isNotEmpty && _sessionPlan[0].workoutSets.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.swipe, color: Colors.white),
              SizedBox(width: 8),
              Text('Swipe left to reveal delete option, release to cancel'),
            ],
          ),
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _hasShownSlideHint = true;
      });
    }
  }
}
