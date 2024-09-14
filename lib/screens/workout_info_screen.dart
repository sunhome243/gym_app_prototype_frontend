import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_services.dart';
import '../widgets/animated_inkwell.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_card.dart';
import '../services/schemas.dart';

class WorkoutInfoScreen extends StatefulWidget {
  final ApiService apiService;

  const WorkoutInfoScreen({super.key, required this.apiService});

  @override
  _WorkoutInfoScreenState createState() => _WorkoutInfoScreenState();
}

class _WorkoutInfoScreenState extends State<WorkoutInfoScreen> {
  Map<String, List<WorkoutInfo>> _workoutsByPart = {};
  List<WorkoutInfo> _filteredWorkouts = [];
  bool _isLoading = true;
  String _selectedPart = 'All';
  String _searchQuery = '';

  final List<String> _workoutParts = [
    'All',
    'Chest',
    'Legs',
    'Back',
    'Arms',
    'Shoulders'
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
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
            colors: const [Color(0xFF4CD964), Colors.white],
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
                        'Workouts',
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
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.4),
          hintStyle: GoogleFonts.lato(color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        style: GoogleFonts.lato(color: Colors.grey),
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
                  color: _selectedPart == part
                      ? const Color(0xFF4CD964)
                      : Colors.grey,
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
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.builder(
              itemCount: _filteredWorkouts.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final workout = _filteredWorkouts[index];
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
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CD964).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForWorkoutPart(workout.workout_part),
                      color: const Color(0xFF4CD964),
                      size: 24,
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

  IconData _getIconForWorkoutPart(String part) {
    switch (part.toLowerCase()) {
      case 'chest':
        return Icons.accessibility_new;
      case 'legs':
        return Icons.directions_run;
      case 'back':
        return Icons.airline_seat_flat;
      case 'arms':
        return Icons.sports_handball;
      case 'shoulders':
        return Icons.expand_more;
      default:
        return Icons.fitness_center;
    }
  }
}

class Background extends StatelessWidget {
  final double height;
  final List<Color> colors;
  final List<double> stops;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final String heroTag;

  const Background({
    super.key,
    required this.height,
    required this.colors,
    required this.stops,
    required this.begin,
    required this.end,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            stops: stops,
            begin: begin,
            end: end,
          ),
        ),
      ),
    );
  }
}
