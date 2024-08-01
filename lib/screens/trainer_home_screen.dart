import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_services.dart';
import '../widgets/animated_inkwell.dart';
import 'member_profile_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/custom_modal.dart';
import '../widgets/custom_menu.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/background.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  _TrainerHomeScreenState createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 1;
  Map<String, dynamic>? _trainerInfo;
  List<dynamic> _members = [];
  bool _isLoading = true;
  bool _isExpanded = false;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sessionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTrainerInfo();
    _fetchMembers();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _sessionsController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrainerInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final trainerInfo = await authService.getCurrentUserInfo();
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

@override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final gradientHeight = screenHeight / 3;
  
  return Scaffold(
    body: Stack(
      children: [
        Background(
          height: screenHeight,
          colors: const [Color(0xFF6EB6FF), Colors.white],
          stops: const [0.0, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          heroTag: 'top_blue_gradient',
        ),
        _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : _buildContent(),
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
                  _buildMyMembersCard(),
                  const SizedBox(height: 20),
                  _buildMembersProgressCard(),
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
      "Ready to inspire?",
      "Time to change lives!",
      "Let's make progress happen!",
      "Your expertise matters today!",
      "Another day to create champions!",
    ];
    return phrases[DateTime.now().microsecond % phrases.length];
  }

  Widget _buildHeader() {
    final firstName = _trainerInfo?['first_name'] ?? 'Trainer';
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

  Widget _buildMyMembersCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isExpanded ? 480 : 220,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Members',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_right,
                            color: Color(0xFF6EB6FF)),
                        onPressed: () {
                          // TODO: Navigate to trainer_manage_members screen
                          print('Navigate to trainer_manage_members screen');
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _isLoading ? _buildSkeletonUI() : _buildMembersGrid(),
                        AnimatedBuilder(
                          animation: _expandAnimation,
                          builder: (context, child) {
                            return SizeTransition(
                              sizeFactor: _expandAnimation,
                              child: child,
                            );
                          },
                          child: _buildExpandedMembersList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: IconButton(
                    key: ValueKey<bool>(_isExpanded),
                    icon: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF6EB6FF),
                      size: 30,
                    ),
                    onPressed: _toggleExpand,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedMembersList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _members.length > 3 ? _members.length - 3 : 0,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _expandAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(_expandAnimation),
                child: child,
              ),
            );
          },
          child: _buildMemberAvatar(_members[index + 3]),
        );
      },
    );
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  Widget _buildSkeletonUI() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _members.length < 3 ? _members.length + 1 : 4,
      itemBuilder: (context, index) {
        if (index < _members.length && index < 3) {
          return _buildMemberAvatar(_members[index]);
        } else if (index == 3) {
          return _buildAddMemberButton();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddMemberButton() {
    return AnimatedInkWell(
      onTap: _showAddMemberModal,
      borderRadius: BorderRadius.circular(30),
      enableFeedback: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFF6EB6FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(dynamic member) {
    final bool isPending = member['status'] == 'pending';
    final bool isRequestor = member['requester_uid'] == _trainerInfo?['uid'];
    final bool isAccepted = member['status'] == 'accepted';
    final int remainingSessions = member['remaining_sessions'] ?? 0;

    String statusText;
    Color statusColor;

    if (isPending) {
      if (isRequestor) {
        statusText = 'Sent';
        statusColor = const Color(0xFFE53935);
      } else {
        statusText = 'Received';
        statusColor = const Color(0xFFE53935);
      }
    } else if (isAccepted) {
      if (remainingSessions <= 3) {
        statusText = 'Critical';
        statusColor = Colors.red;
      } else if (remainingSessions <= 5) {
        statusText = 'Low';
        statusColor = Colors.orange;
      } else {
        statusText = 'All Set';
        statusColor = const Color(0xFF81C784);
      }
    } else {
      statusText = '';
      statusColor = Colors.transparent;
    }

    return AnimatedInkWell(
      onTap: () {
        if (isPending && !isRequestor) {
          _showApprovalModal(member);
        } else if (isAccepted) {
          // TODO: Navigate to profile page
          print('Navigating to profile page');
        }
      },
      onLongPress: (Offset tapPosition) {
        _showDeleteMenu(context, member, tapPosition);
      },
      splashColor: const Color(0xFF6EB6FF).withOpacity(0.3),
      borderRadius: BorderRadius.circular(30),
      enableFeedback: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${member['member_first_name'][0]}${member['member_last_name'][0]}',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6EB6FF),
                    ),
                  ),
                ),
              ),
              if (statusText.isNotEmpty)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${member['member_first_name']} ${member['member_last_name']}',
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF424242),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (statusText.isNotEmpty)
            Text(
              statusText,
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteMenu(BuildContext context, dynamic member, Offset tapPosition) {
    showCustomMenu(
      context,
      tapPosition,
      [
        CustomMenuItem(
          icon: Icons.delete_outline,
          text: 'Remove',
          onTap: () {
            _showDeleteConfirmationModal(context, member);
          },
          color: Colors.red,
        ),
      ],
    );
  }

  void _showDeleteConfirmationModal(BuildContext context, dynamic member) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          title: 'Remove Member',
          icon: Icons.warning,
          theme: CustomModalTheme.red,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to remove ${member['member_first_name']} from your member list?',
                style: GoogleFonts.lato(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'This action cannot be undone!',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            CustomModalAction(
              text: 'Cancel',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            CustomModalAction(
              text: 'Remove',
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _removeMember(member);
              },
              isDefaultAction: true,
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeMember(dynamic member) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.removeTrainerMemberMapping(member['member_email']);
      await _fetchMembers();
      _showSuccessDialog(context, 'Member removed successfully');
    } catch (e) {
      _showErrorDialog(context, 'Failed to remove member: $e');
    }
  }

  Widget _buildMembersProgressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members\' Progress',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Weekly Progress Overview',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Progress chart will be implemented here',
                  style: GoogleFonts.lato(color: Colors.grey[600]),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement view all progress functionality
                },
                child: const Text('View All'),
              ),
            ),
          ],
        ),
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

  void _showAddMemberModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomModal(
          title: 'Add New Member',
          icon: Icons.person_add,
          theme: CustomModalTheme.blue,
          content: Column(
            children: [
              _buildTextField(
                controller: _emailController,
                label: 'Member Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _sessionsController,
                label: 'Initial Sessions',
                icon: Icons.fitness_center,
                keyboardType: TextInputType.number,
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
              onPressed: () {
                Navigator.of(context).pop();
                _addMember();
              },
              isDefaultAction: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6EB6FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6EB6FF), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6EB6FF), width: 2),
        ),
      ),
    );
  }

  Future<void> _addMember() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.requestTrainerMemberMapping(
        _emailController.text,
        int.parse(_sessionsController.text),
      );
      _showSuccessDialog(context, 'Member request sent successfully');
      _emailController.clear();
      _sessionsController.clear();
      _animationController.reverse();
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

  void _showApprovalModal(dynamic member) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          title: 'New Member Request',
          icon: Icons.person_add,
          theme: CustomModalTheme.blue,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${member['member_first_name']} ${member['member_last_name']} wants to join your fitness squad!',
                style: GoogleFonts.lato(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Ready to welcome them to the gains train?',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            CustomModalAction(
              text: 'Not Now',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            CustomModalAction(
              text: 'Accept',
              onPressed: () async {
                final apiService =
                    Provider.of<ApiService>(context, listen: false);
                if (member['mapping_id'] != null) {
                  await apiService.updateTrainerMemberMappingStatus(
                      member['mapping_id'], 'accepted');
                  Navigator.of(dialogContext).pop();
                  _fetchMembers();
                  _showSuccessDialog(context, 'New member added successfully!');
                } else {
                  _showErrorDialog(context, 'An error occurred. Please try again.');
                }
              },
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
      targetScreen: const MemberProfileScreen(),
    ),
  ];
}