import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/animated_inkwell.dart';
import 'all_sessions_screen.dart';
import 'member_profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/background.dart';
import '../widgets/skeleton_ui_widgets.dart';

class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MemberHomeScreen> {
  int _selectedIndex = 1;
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
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
        _errorMessage = 'Error fetching user info: $e';
        _isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final gradientHeight = screenHeight / 3;
  
  return Scaffold(
    body: Stack(
      children: [
        Background(
          height: screenHeight,
          colors: const [Color(0xFF4CD964), Colors.white],
          stops: const [0.0, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          heroTag: 'top_green_gradient',
        ),
        _buildContent(),
      ],
    ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _buildStartSessionButton(),
        ),
        CustomBottomNavBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          onIndexChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ],
    ),
  );
}

  Widget _buildSkeletonUI() {
    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonHeader(),
          const Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SkeletonCard(),
                    SizedBox(height: 20),
                    SkeletonCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 200, height: 24),
                SizedBox(height: 8),
                SkeletonText(width: 150, height: 16),
              ],
            ),
          ),
          SkeletonAvatar(),
        ],
      ),
    );
  }
  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRecordsCard(),
                  const SizedBox(height: 20),
                  _buildRecentSessionsCard(),
                  const SizedBox(height: 100), // Space for the fixed button
                ],
              ),
            ),
          ),
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

  Widget _buildHeader() {
    final firstName = _userInfo?['first_name'] ?? 'Member';
    final greeting = _getGreeting();
    final motivationalPhrase = _getMotivationalPhrase();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $firstName!',
                  style: GoogleFonts.lato(
                    fontSize: 24,
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
                    color: Colors.black54,
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
                color: Colors.white.withOpacity(0.1),
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
    );
  }

  Widget _buildRecordsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Records',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Weekly Workout Progress',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Graph will be implemented here',
                  style: GoogleFonts.lato(color: Colors.grey[600]),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement view all functionality
                },
                child: const Text('View All'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Recent Sessions',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildSessionItem(
                '1', Colors.blue, '2024.02.01', 'PT Session with Jane'),
            _buildSessionItem(
                '2', Colors.green, '2024.01.31', 'Custom Individual Workout'),
            _buildSessionItem(
                '3', Colors.blue, '2024.01.30', 'PT Session with Jane'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllSessionsScreen()),
                  );
                },
                child: const Text('View All'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(
      String number, Color color, String date, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.lato(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: GoogleFonts.lato(
                        color: Colors.grey[600], fontSize: 12)),
                Text(title,
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildStartSessionButton() {
    return AnimatedInkWell(
      onTap: () {
        // TODO: Implement start new session functionality
      },
      splashColor: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            'Start new Session',
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