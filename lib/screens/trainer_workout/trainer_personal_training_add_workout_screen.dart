import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/animated_inkwell.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/background.dart';
import '../../services/api_services.dart';
import '../../services/schemas.dart';
import 'dart:math' show pi;

class TrainerPersonalTrainingAddWorkoutScreen extends StatefulWidget {
  final ApiService apiService;
  final List<WorkoutInfo> initialSessionPlan;

  const TrainerPersonalTrainingAddWorkoutScreen({
    Key? key,
    required this.apiService,
    this.initialSessionPlan = const [],
  }) : super(key: key);

  @override
  _TrainerPersonalTrainingAddWorkoutScreenState createState() =>
      _TrainerPersonalTrainingAddWorkoutScreenState();
}

class _TrainerPersonalTrainingAddWorkoutScreenState
    extends State<TrainerPersonalTrainingAddWorkoutScreen>
    with TickerProviderStateMixin {
  Map<String, List<WorkoutInfo>> _workoutsByPart = {};
  List<WorkoutInfo> _filteredWorkouts = [];
  List<WorkoutInfo> _sessionPlan = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String _selectedPart = 'All';

  final List<String> _workoutParts = [
    'All',
    'Chest',
    'Legs',
    'Back',
    'Arms',
    'Shoulders'
  ];

  late final Map<String, AnimationController> _iconAnimationControllers = {};

  final ScrollController _workoutListScrollController = ScrollController();

  final Color _themeColor = const Color(0xFF6EB6FF);

  @override
  void initState() {
    super.initState();
    _sessionPlan = List.from(widget.initialSessionPlan);
    _loadWorkouts();

    for (var workout in _sessionPlan) {
      _iconAnimationControllers[workout.workout_name] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
        value: 1.0,
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _iconAnimationControllers.values) {
      controller.dispose();
    }
    _workoutListScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    try {
      final workouts = await widget.apiService.getWorkoutsByPart();
      setState(() {
        _workoutsByPart = workouts;
        _isLoading = false;
      });
      _filterWorkouts();
    } catch (e) {
      print('Error loading workouts: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load workouts. Please try again.')),
      );
    }
  }

  void _filterWorkouts() {
    List<WorkoutInfo> workouts = [];
    if (_selectedPart == 'All') {
      _workoutsByPart.forEach((part, partWorkouts) {
        workouts.addAll(partWorkouts);
      });
    } else {
      workouts = _workoutsByPart[_selectedPart] ?? [];
    }

    if (_searchQuery.isNotEmpty) {
      workouts = workouts
          .where((workout) => workout.workout_name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredWorkouts = workouts;
    });
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      const CustomBackButton(),
                      const SizedBox(width: 8),
                      Text(
                        'Add Workout',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: 16),
                _buildWorkoutPartFilter(),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildWorkoutList(),
                ),
                const SizedBox(height: 16),
                _buildSessionPlanList(),
                _buildDoneButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 40,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _filterWorkouts();
        },
        decoration: InputDecoration(
          hintText: 'Search workouts',
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          hintStyle: GoogleFonts.lato(color: Colors.white70),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        style: GoogleFonts.lato(color: Colors.white),
      ),
    );
  }

  Widget _buildWorkoutPartFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _workoutParts.length,
        itemBuilder: (context, index) {
          final part = _workoutParts[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 8 : 8, right: 4),
            child: AnimatedInkWell(
              onTap: () {
                setState(() {
                  _selectedPart = _selectedPart == part ? 'All' : part;
                });
                _filterWorkouts();
              },
              child: Chip(
                label: Text(part),
                backgroundColor: _selectedPart == part
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                labelStyle: GoogleFonts.lato(
                  color: _selectedPart == part ? _themeColor : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomCard(
        title: 'Available Workouts',
        titleColor: Colors.black,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.356,
            child: ListView.builder(
              controller: _workoutListScrollController,
              itemCount: _filteredWorkouts.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final workout = _filteredWorkouts[index];
                final isAdded = _sessionPlan.contains(workout);

                _iconAnimationControllers[workout.workout_name] ??= AnimationController(
                  duration: const Duration(milliseconds: 300),
                  vsync: this,
                  value: isAdded ? 1.0 : 0.0,
                );

                final iconAnimationController = _iconAnimationControllers[workout.workout_name]!;

                return ListTile(
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
                      color: Colors.black54,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => _toggleWorkout(workout),
                    child: AnimatedBuilder(
                      animation: iconAnimationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: iconAnimationController.value * pi / 4,
                          child: Icon(
                            Icons.add_circle_outline,
                            color: Color.lerp(Colors.green, Colors.red, iconAnimationController.value),
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionPlanList() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Session Plan',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sessionPlan.length,
              itemBuilder: (context, index) {
                final workout = _sessionPlan[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Chip(
                    label: Text(workout.workout_name),
                    onDeleted: () => _toggleWorkout(workout),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    backgroundColor: _themeColor.withOpacity(0.1),
                    deleteIconColor: Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedInkWell(
        onTap: () => Navigator.pop(context, _sessionPlan),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _themeColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Done',
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

  void _toggleWorkout(WorkoutInfo workout) {
    final isAdded = _sessionPlan.contains(workout);
    final controller = _iconAnimationControllers[workout.workout_name]!;

    setState(() {
      if (isAdded) {
        _removeFromSessionPlan(workout);
        controller.reverse();
      } else {
        _addToSessionPlan(workout);
        controller.forward();
      }
    });
  }

  void _addToSessionPlan(WorkoutInfo workout) {
    if (!_sessionPlan.contains(workout)) {
      setState(() {
        _sessionPlan.add(workout);
      });
    }
  }

  void _removeFromSessionPlan(WorkoutInfo workout) {
    setState(() {
      _sessionPlan.remove(workout);
    });
  }
}