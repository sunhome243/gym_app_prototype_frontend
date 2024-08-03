import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/animated_inkwell.dart';
import '../widgets/quick_action_button.dart'; // Import the new widget
import 'all_sessions_screen.dart';
import 'member_profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/skeleton_ui_widgets.dart';
import 'manage_trainer.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _isLoading ? _buildSkeletonUI() : _buildContent(),
                ),
                _buildStartSessionButton(),
              ],
            ),
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

  Widget _buildBackground() {
    return Hero(
      tag: 'background_top',
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CD964), Colors.white],
            stops: [0.0, 0.5],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonUI() {
    return const ShimmerLoading(
      child: Column(
        children: [
          SkeletonCard(),
          SizedBox(height: 20),
          SkeletonCard(),
          SizedBox(height: 20),
          SkeletonCard(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildWorkoutSummary(),
          const SizedBox(height: 24),
          _buildRecentSessionsCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final firstName = _userInfo?['first_name'] ?? 'Member';
    final greeting = _getGreeting();
    final motivationalPhrase = _getMotivationalPhrase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $firstName!',
                    style: GoogleFonts.lato(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    motivationalPhrase,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedInkWell(
              onTap: () {
                // TODO: Implement notification functionality
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  String _getMotivationalPhrase() {
    final phrases = [
      "Let's crush your goals!",
      "Time to level up!",
      "Your strength awaits!",
      "Progress starts now!",
      "Embrace the challenge!",
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
        Hero(
          tag: 'trainerButton',
          child: QuickActionButton(
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
        ),
      ],
    );
  }

  Widget _buildWorkoutSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week\'s Progress',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressItem('Workouts', '4/5'),
                _buildProgressItem('Calories', '1,200'),
                _buildProgressItem('Time', '3h 45m'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4CD964),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Sessions',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllSessionsScreen()),
                    );
                  },
                  child: Text(
                    'View All',
                    style: GoogleFonts.lato(
                      color: const Color(0xFF4CD964),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSessionItem('1', const Color(0xFF4CD964), '2024.02.01',
                'PT Session with Jane'),
            _buildSessionItem(
                '2', Colors.blue, '2024.01.31', 'Custom Individual Workout'),
            _buildSessionItem('3', const Color(0xFF4CD964), '2024.01.30',
                'PT Session with Jane'),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(
      String number, Color color, String date, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.lato(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStartSessionButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedInkWell(
        onTap: () {
          // TODO: Implement start new session functionality
        },
        splashColor: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
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