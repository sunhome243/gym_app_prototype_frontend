import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/animated_inkwell.dart';
import 'trainer_profile_screen.dart';
import 'trainer_workout/trainer_workout_init_screen.dart';
import '../widgets/custom_modal.dart';
import '../widgets/custom_menu.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/skeleton_ui_widgets.dart';
import 'trainer_member_all_sessions_screen.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  _TrainerHomeScreenState createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  int _selectedIndex = 1;
  Map<String, dynamic>? _trainerInfo;
  List<dynamic> _members = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _sessionsToday = 0;

  @override
  void initState() {
    super.initState();
    _fetchTrainerInfo();
    _fetchMembers();
    _fetchSessionsToday();
  }

  Future<void> _fetchSessionsToday() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final sessions = await apiService.getTrainerMemberSessions();
      final today = DateTime.now().toLocal().toString().split(' ')[0];
      final sessionsToday = sessions
          .where((session) => session.workout_date.startsWith(today))
          .length;
      setState(() {
        _sessionsToday = sessionsToday;
      });
    } catch (e) {
      print('Error fetching sessions today: $e');
    }
  }

  Future<void> _fetchTrainerInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final trainerInfo = await apiService.getTrainerInfo();
      setState(() {
        _trainerInfo = trainerInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching trainer info: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMembers() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final members = await apiService.getMyMappings();
      setState(() {
        _members = members;
      });
    } catch (e) {
      print('Error fetching members with sessions: $e');
    }
  }

  void _updateSessionsToday(int count) {
    setState(() {
      _sessionsToday = count;
    });
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
                        const Color(0xFF6EB6FF),
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
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    _buildQuickActions(),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    _buildMyMembersCard(constraints),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    _buildMembersProgressCard(),
                    SizedBox(height: constraints.maxHeight * 0.03),
                    _buildStartSessionButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreeting() {
    final firstName = _trainerInfo?['first_name'] ?? 'Trainer';
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
      "Ready to inspire?",
      "Time to change lives!",
      "Let's make progress happen!",
      "Your expertise matters today!",
      "Another day to create champions!",
    ];
    return phrases[DateTime.now().microsecond % phrases.length];
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        QuickActionButton(
          icon: Icons.group,
          label: 'Members',
          iconColor: const Color(0xFF6EB6FF),
          onTap: () {
            // TODO: Navigate to Members management screen
          },
        ),
        QuickActionButton(
          icon: Icons.insights,
          label: 'Progress',
          iconColor: const Color(0xFF6EB6FF),
          onTap: () {
            // TODO: Navigate to Progress overview screen
          },
        ),
        QuickActionButton(
          icon: Icons.edit_document,
          label: 'Record',
          iconColor: const Color(0xFF6EB6FF),
          onTap: () {
            // TODO: Navigate to Schedule management screen
          },
        ),
        QuickActionButton(
          icon: Icons.list,
          label: 'All Sessions',
          iconColor: const Color(0xFF6EB6FF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainerMemberAllSessionsScreen(
                  refreshHomeScreen: _updateSessionsToday,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMyMembersCard(BoxConstraints constraints) {
    return CustomCard(
      title: "My Members",
      titleColor: Colors.black,
      titleFontSize: 18,
      trailing: GestureDetector(
        onTap: () {
          // TODO: Navigate to full members list
        },
        child: const Icon(Icons.arrow_forward_ios,
            color: Color(0xFF6EB6FF), size: 20),
      ),
      children: [
        SizedBox(
          height: constraints.maxHeight * 0.12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _buildMemberAvatars(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMemberAvatars() {
    List<Widget> avatars = [];

    if (_members.isEmpty) {
      avatars.add(_buildAddMemberButton());
    } else if (_members.length <= 3) {
      for (var member in _members) {
        avatars.add(Padding(
          padding: const EdgeInsets.only(right: 15),
          child: _buildMemberAvatar(member),
        ));
      }
      avatars.add(_buildAddMemberButton());
    } else {
      for (int i = 0; i < 3; i++) {
        avatars.add(Padding(
          padding: const EdgeInsets.only(right: 15),
          child: _buildMemberAvatar(_members[i]),
        ));
      }
      avatars.add(Padding(
        padding: const EdgeInsets.only(right: 15),
        child: _buildMoreMembersIndicator(),
      ));
      avatars.add(_buildAddMemberButton());
    }

    return avatars;
  }

  Widget _buildMemberAvatar(dynamic member) {
    final bool isPending = member['status'] == 'pending';
    final bool isAccepted = member['status'] == 'accepted';
    final int remainingSessions = member['remaining_sessions'] ?? 0;

    Color statusColor = const Color(0xFF81C784); // 기본 초록색
    if (isPending) {
      statusColor = Colors.grey;
    } else if (isAccepted && remainingSessions <= 3) {
      statusColor = Colors.red;
    } else if (isAccepted && remainingSessions <= 5) {
      statusColor = Colors.orange;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isPending ? Colors.grey : const Color(0xFF6EB6FF),
                    isPending
                        ? Colors.grey.withOpacity(0.7)
                        : const Color(0xFF6EB6FF).withOpacity(0.7),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  '${member['member_first_name'][0]}${member['member_last_name'][0]}',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (isPending)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: const Icon(Icons.hourglass_empty,
                      size: 12, color: Colors.grey),
                ),
              )
            else
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          member['member_first_name'],
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMoreMembersIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF6EB6FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '+${_members.length - 3}',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6EB6FF),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'More',
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6EB6FF),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMemberButton() {
    return GestureDetector(
      onTap: _showAddMemberModal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6EB6FF).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFF6EB6FF),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.add,
              color: Color(0xFF6EB6FF),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6EB6FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersProgressCard() {
    return CustomCard(
      title: "Members' Progress",
      titleColor: Colors.black,
      titleFontSize: 18,
      trailing: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainerMemberAllSessionsScreen(
                refreshHomeScreen: _updateSessionsToday,
              ),
            ),
          );
        },
        child: const Icon(Icons.arrow_forward_ios,
            color: Color(0xFF6EB6FF), size: 20),
      ),
      children: [
        SizedBox(
          height: 120, // 기존 높이 유지
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: _buildProgressItem(
                      'Active\nMembers', '${_members.length}', Icons.group)),
              Expanded(
                  child: _buildProgressItem(
                      'Sessions\nToday', '$_sessionsToday', Icons.today)),
              Expanded(
                  child: _buildProgressItem(
                      'Avg.\nProgress', '75%', Icons.trending_up)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8), // 좌우 패딩 추가
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF6EB6FF), size: 30), // 아이콘 크기 약간 증가
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 17, // 값 텍스트 크기 약간 증가
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11, // 레이블 텍스트 크기 유지
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStartSessionButton() {
    return AnimatedInkWell(
      onTap: () {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final trainerUid = _trainerInfo?['uid'];
        if (trainerUid != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainerWorkoutInitScreen(
                apiService: apiService,
                trainerUid: trainerUid,
              ),
            ),
          );
        } else {
          // trainerUid가 null인 경우 에러 처리
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Trainer information not available. Please try again.')),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF6EB6FF),
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

  void _showAddMemberModal() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController sessionsController = TextEditingController();

    showCustomModal(
      context: context,
      title: 'Add New Member',
      theme: CustomModalTheme.blue,
      icon: Icons.person_add,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Member Email',
              prefixIcon: const Icon(Icons.email, color: Color(0xFF6EB6FF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF6EB6FF), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: sessionsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Initial Sessions',
              prefixIcon:
                  const Icon(Icons.fitness_center, color: Color(0xFF6EB6FF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF6EB6FF), width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        CustomModalAction(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomModalAction(
          text: 'Add Member',
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
            _addMember(
                emailController.text, int.parse(sessionsController.text));
          },
        ),
      ],
    );
  }

  Future<void> _addMember(String email, int initialSessions) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.requestTrainerMemberMapping(email, initialSessions);
      _showSuccessDialog(context, 'Member request sent successfully');
      _fetchMembers(); // Refresh the member list
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('not found')) {
        errorMessage =
            'We couldn\'t find a member with that email. Double-check the address and try again!';
      } else if (e
          .toString()
          .contains('Mapping already exists and is accepted')) {
        errorMessage =
            'Great news! You\'re already connected with this member. No need to reconnect. You\'re all set to start training!';
      } else if (e
          .toString()
          .contains('Mapping already exists and is pending')) {
        errorMessage =
            'You\'ve already sent a request to this member. They\'re probably just warming up before accepting. Hang tight!';
      } else {
        errorMessage = 'Whoa, where are we? Can we try that again?';
      }
      _showErrorDialog(context, errorMessage);
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          title: 'Success',
          icon: Icons.check_circle_outline,
          theme: CustomModalTheme.green,
          content: Text(
            message,
            style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            CustomModalAction(
              text: 'OK',
              onPressed: () => Navigator.of(dialogContext).pop(),
              isDefaultAction: true,
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          title: 'Error',
          icon: Icons.error_outline,
          theme: CustomModalTheme.red,
          content: Text(
            message,
            style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            CustomModalAction(
              text: 'OK',
              onPressed: () => Navigator.of(dialogContext).pop(),
              isDefaultAction: true,
            ),
          ],
        );
      },
    );
  }

  final List<CustomBottomNavItem> _navItems = [
    CustomBottomNavItem(
      icon: Icons.menu,
      targetScreen: const Center(child: Text('Menu Screen')),
    ),
    CustomBottomNavItem(
      icon: Icons.home,
      targetScreen: const TrainerHomeScreen(),
    ),
    CustomBottomNavItem(
      icon: Icons.person,
      targetScreen: const TrainerProfileScreen(),
    ),
  ];
}
