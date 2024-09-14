import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_inkwell.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_card.dart';
import '../services/api_services.dart';
import 'member_custom_workout_init.dart';

class TrainerWorkoutInitScreen extends StatefulWidget {
  final ApiService apiService;

  const TrainerWorkoutInitScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  _TrainerWorkoutInitScreenState createState() => _TrainerWorkoutInitScreenState();
}

class _TrainerWorkoutInitScreenState extends State<TrainerWorkoutInitScreen> {
  Color _backgroundColor = const Color(0xFF6F42C1);
  String _selectedMember = '';
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final members = await widget.apiService.getMyMappings();
      setState(() {
        _members = members.where((member) => member['status'] == 'accepted').toList();
      });
    } catch (e) {
      print('Error fetching members: $e');
      // Consider showing an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            right: -size.width * 1.5,
            bottom: -size.height * 1.5,
            child: SizedBox(
              width: size.width * 4,
              height: size.height * 4,
              child: Hero(
                tag: 'background',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_backgroundColor, Colors.white.withOpacity(0)],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      const CustomBackButton(),
                      const SizedBox(width: 16),
                      Text(
                        'Start Training Session',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomCard(
                              title: 'Select Member',
                              titleColor: Colors.black,
                              children: [
                                if (_members.isEmpty)
                                  _buildEmptyState()
                                else
                                  ..._members.map((member) => _buildMemberOption(member)),
                              ],
                            ),
                            const SizedBox(height: 40),
                            AnimatedInkWell(
                              onTap: _selectedMember.isNotEmpty
                                  ? _navigateToCustomWorkout
                                  : null,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: _selectedMember.isNotEmpty
                                      ? const Color(0xFF6F42C1)
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Next',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberOption(Map<String, dynamic> member) {
    final fullName = '${member['member_first_name']} ${member['member_last_name']}';
    return AnimatedInkWell(
      onTap: () {
        setState(() {
          _selectedMember = member['uid'];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _selectedMember == member['uid']
              ? const Color(0xFF6F42C1).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedMember == member['uid'] ? const Color(0xFF6F42C1) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF6F42C1),
              child: Text(
                fullName.split(' ').map((e) => e[0]).join('').toUpperCase(),
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                fullName,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (_selectedMember == member['uid'])
              const Icon(Icons.check_circle, color: Color(0xFF6F42C1), size: 24),
          ],
        ),
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
            Icon(Icons.people, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No members available',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add members to start training sessions',
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

  void _navigateToCustomWorkout() {
    final selectedMemberInfo = _members.firstWhere((member) => member['uid'] == _selectedMember);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWorkoutInitScreen(
          apiService: widget.apiService,
          workoutType: 3, // Custom workout type
          memberUid: _selectedMember,
          memberName: '${selectedMemberInfo['member_first_name']} ${selectedMemberInfo['member_last_name']}',
        ),
      ),
    );
  }
}