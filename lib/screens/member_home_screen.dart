import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/background.dart';
import '../widgets/custom_card.dart';
import '../widgets/animated_inkwell.dart';
import 'all_sessions_screen.dart';
import 'member_profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/skeleton_ui_widgets.dart';
import 'manage_trainer.dart';
import 'member_workout_init_screen.dart';


class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({super.key});
  
  @override
  _MemberHomeScreenState createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  int _selectedIndex = 1;
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final userInfo = await apiService.getMemberInfo();
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            right: -size.width * 3.5,
            bottom: -size.height * 1,
            child: SizedBox(
              width: size.width * 8,
              height: size.height * 4,
              child: Hero(
                tag: 'background_top',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3CD687),
                        Colors.white.withOpacity(0)
                      ],
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: _isLoading ? _buildSkeletonUI() : _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onIndexChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSkeletonUI() {
    return const ShimmerLoading(
      child: Column(
        children: [
          SkeletonCard(),
          SizedBox(height: 16),
          SkeletonCard(),
          SizedBox(height: 16),
          SkeletonCard(),
        ],
      ),
    );
  }

Widget _buildContent() {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 3, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            SizedBox(height: constraints.maxHeight * 0.02),
            _buildQuickActions(),
            SizedBox(height: constraints.maxHeight * 0.02),
            Expanded(
              flex: 3,
              child: _buildWorkoutSummaryCard(),
            ),
            SizedBox(height: constraints.maxHeight * 0.02),
            Expanded(
              flex: 4,
              child: _buildRecentSessionsCard(),
            ),
            SizedBox(height: constraints.maxHeight * 0.02),
            _buildStartSessionButton(),
          ],
        ),
      );
    },
  );
}

  Widget _buildGreeting() {
    final firstName = _userInfo?['first_name'] ?? 'Member';
    final greeting = _getGreeting();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.lato(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          firstName,
          style: GoogleFonts.lato(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getMotivationalPhrase(),
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning,";
    } else if (hour < 17) {
      return "Good afternoon,";
    } else {
      return "Good evening,";
    }
  }

  String _getMotivationalPhrase() {
    final phrases = [
      "Let's crush your goals today!",
      "Time to level up your fitness!",
      "Your strength journey continues!",
      "Progress starts with your next move!",
      "Embrace the challenge ahead!",
    ];
    return phrases[DateTime.now().microsecond % phrases.length];
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        QuickActionButton(
          icon: Icons.fitness_center,
          label: 'Workouts',
          iconColor: const Color(0xFF4CD964),
          onTap: () {
            // TODO: Add functionality for Workouts
          },
        ),
        QuickActionButton(
          icon: Icons.insights,
          label: 'Progress',
          iconColor: const Color(0xFF4CD964),
          onTap: () {
            // TODO: Add functionality for Progress
          },
        ),
        QuickActionButton(
          icon: Icons.person,
          label: 'Trainer',
          iconColor: const Color(0xFF4CD964),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageTrainerScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

Widget _buildWorkoutSummaryCard() {
  return CustomCard(
    title: "This Week's Progress",
    titleColor: Colors.black,
    titleFontSize: 18,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildProgressItem('Workouts', '4/5', Icons.fitness_center),
            _buildProgressItem('Calories', '1,200', Icons.local_fire_department),
            _buildProgressItem('Time', '3h 45m', Icons.timer),
          ],
        ),
      ),
    ],
  );
}

Widget _buildProgressItem(String label, String value, IconData icon) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: const Color(0xFF4CD964), size: 24),
      const SizedBox(height: 7),
      Text(
        value,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}

Widget _buildRecentSessionsCard() {
  return CustomCard(
    title: 'Recent Sessions',
    titleColor: Colors.black,
    titleFontSize: 18,
    trailing: AnimatedInkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllSessionsScreen()),
        );
      },
      child: const Icon(Icons.arrow_forward, color: Color(0xFF4CD964), size: 24),
    ),
    children: [
      Column(
        children: List.generate(2, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CD964).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center, color: Color(0xFF4CD964), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Body Workout',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]} • 45 min',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ],
  );
}

Widget _buildStartSessionButton() {
  return AnimatedInkWell(
    onTap: () {
      final apiService = Provider.of<ApiService>(context, listen: false);
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MemberWorkoutInitScreen(apiService: apiService),
          transitionDuration: Duration.zero, // Instantly transition
        ),
      );
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF4CD964),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Start New Session',
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}

  final List<CustomBottomNavItem> _navItems = [
    CustomBottomNavItem(
      icon: Icons.menu,
      targetScreen: const Center(child: Text('Menu Screen')),
    ),
    CustomBottomNavItem(
      icon: Icons.home,
      targetScreen: const MemberHomeScreen(),
    ),
    CustomBottomNavItem(
      icon: Icons.person,
      targetScreen: const MemberProfileScreen(),
    ),
  ];
}