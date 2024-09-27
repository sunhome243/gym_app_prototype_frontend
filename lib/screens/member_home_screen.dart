import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/animated_inkwell.dart';
import 'all_sessions_screen.dart';
import 'member_profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/skeleton_ui_widgets.dart';
import 'manage_trainer.dart';
import 'member_workout/member_workout_init_screen.dart';
import 'workout_info_screen.dart';
import 'package:intl/intl.dart';
import '../services/schemas.dart';
import 'package:flutter/foundation.dart';

class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({super.key});

  @override
  _MemberHomeScreenState createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  int _selectedIndex = 1;
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  List<SessionWithSets> _recentSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchRecentSessions();
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

  Future<void> _fetchRecentSessions() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final sessions = await apiService.getSessions();
      sessions.sort((a, b) => b.workout_date.compareTo(a.workout_date));
      if (!listEquals(_recentSessions, sessions)) {
        setState(() {
          _recentSessions = sessions;
        });
      }
    } catch (e) {
      print('Error fetching recent sessions: $e');
    }
  }

  Future<void> refreshRecentSessions() async {
    await _fetchRecentSessions();
    setState(() {}); // UI 업데이트를 트리거합니다.
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
                flex: 2,
                child: _buildWorkoutSummaryCard(),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              Expanded(
                flex: 3,
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
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          firstName,
          style: GoogleFonts.lato(
            fontSize: 24,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WorkoutInfoScreen(
                      apiService:
                          Provider.of<ApiService>(context, listen: false))),
            );
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
      titleFontSize: 17,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressItem('Workouts', '4/5', Icons.fitness_center),
              _buildProgressDivider(),
              _buildProgressItem(
                  'Calories', '1,200', Icons.local_fire_department),
              _buildProgressDivider(),
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
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildProgressDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildRecentSessionsCard() {
    return CustomCard(
      title: 'Recent Sessions',
      titleColor: Colors.black,
      titleFontSize: 17,
      trailing: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AllSessionsScreen(
                    refreshRecentSessions: refreshRecentSessions)),
          );
        },
        child: const Icon(Icons.arrow_forward_ios,
            color: Color(0xFF4CD964), size: 17),
      ),
      children: [
        SizedBox(
          height: 150,
          child: FutureBuilder<List<SessionWithSets>>(
            future:
                Provider.of<ApiService>(context, listen: false).getSessions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildNoSessionsWidget();
              } else {
                final recentSessions = snapshot.data!.take(2).toList();
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: recentSessions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Colors.grey),
                  itemBuilder: (context, index) {
                    return _buildSessionItem(recentSessions[index]);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoSessionsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 48,
              color: Color(0xFF4CD964),
            ),
            const SizedBox(height: 12),
            Text(
              "No sessions yet",
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "Start your fitness journey today!",
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(SessionWithSets session) {
    IconData iconData;
    Color iconColor;
    String sessionType;

    if (session.is_pt) {
      iconData = Icons.person;
      iconColor = Colors.blue;
      sessionType = 'PT Session';
    } else if (session.session_type_id == 1) {
      iconData = Icons.auto_awesome;
      iconColor = Colors.purple;
      sessionType = 'AI Workout';
    } else {
      iconData = Icons.fitness_center;
      iconColor = Colors.green;
      sessionType = 'Custom Workout';
    }

    String formattedDate = 'No date';
    if (session.workout_date.isNotEmpty) {
      try {
        DateTime dateTime = DateTime.parse(session.workout_date);
        formattedDate = DateFormat('MMM d, yyyy - HH:mm').format(dateTime);
      } catch (e) {
        print('Error parsing date: ${e.toString()}');
        formattedDate = 'Invalid date';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sessionType,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartSessionButton() {
    return AnimatedInkWell(
      onTap: () {
        final apiService = Provider.of<ApiService>(context, listen: false);
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MemberWorkoutInitScreen(
              apiService: apiService,
              refreshRecentSessions: refreshRecentSessions, // 여기에 추가
            ),
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
