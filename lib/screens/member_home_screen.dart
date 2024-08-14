import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/background.dart';
import '../widgets/custom_card.dart';
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
          Background(
            height: MediaQuery.of(context).size.height,
            colors: const [Color(0xFF3CD687), Colors.white],
            stops: const [0.0, 0.3],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            heroTag: 'background_top',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final firstName = _userInfo?['first_name'] ?? 'Member';
    final greeting = _getGreeting();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          firstName,
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getMotivationalPhrase(),
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.6),
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

  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: _buildWorkoutSummaryCard(),
        ),
        const SizedBox(height: 8), // Reduced space between cards
        Expanded(
          flex: 6,
          child: _buildRecentSessionsCard(),
        ),
        const SizedBox(height: 16),
        _buildStartSessionButton(),
      ],
    );
  }

  Widget _buildWorkoutSummaryCard() {
    return CustomCard(
      title: "This Week's Progress",
      titleColor: Colors.black,
      titleFontSize: 18,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildProgressItem('Workouts', '4/5', Icons.fitness_center),
            _buildProgressItem('Calories', '1,200', Icons.local_fire_department),
            _buildProgressItem('Time', '3h 45m', Icons.timer),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF4CD964), size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
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
      trailing: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AllSessionsScreen()),
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
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent sessions',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a new session to see it here',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartSessionButton() {
    return CustomUpdateButton(
      onPressed: () {
        // TODO: Implement start new session functionality
      },
      text: 'Start New Session',
      backgroundColor: const Color(0xFF4CD964),
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