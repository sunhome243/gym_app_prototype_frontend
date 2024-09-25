import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/animated_inkwell.dart';
import 'trainer_profile_screen.dart';
import 'trainer_workout_init_screen.dart';
import '../widgets/custom_modal.dart';
import '../widgets/custom_menu.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/skeleton_ui_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchTrainerInfo();
    _fetchMembers();
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
                child: _buildMyMembersCard(),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              Expanded(
                flex: 4,
                child: _buildMembersProgressCard(),
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
      ],
    );
  }

  Widget _buildMyMembersCard() {
    return CustomCard(
      title: "My Members",
      titleColor: Colors.black,
      titleFontSize: 18,
      trailing: AnimatedInkWell(
        onTap: _showAddMemberModal,
        child: const Icon(Icons.add, color: Color(0xFF6EB6FF), size: 24),
      ),
      children: [
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _members.length + 1,
            itemBuilder: (context, index) {
              if (index < _members.length) {
                return _buildMemberAvatar(_members[index]);
              } else {
                return _buildAddMemberButton();
              }
            },
          ),
        ),
      ],
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
      statusText = isRequestor ? 'Sent' : 'Received';
      statusColor = const Color(0xFFE53935);
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AnimatedInkWell(
        onTap: () {
          if (isPending && !isRequestor) {
            _showApprovalModal(member);
          } else if (isAccepted) {
            // TODO: Navigate to member profile page
          }
        },
        onLongPress: (Offset tapPosition) {
          _showDeleteMenu(context, member, tapPosition);
        },
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF6EB6FF),
                  child: Text(
                    '${member['member_first_name'][0]}${member['member_last_name'][0]}',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (statusText.isNotEmpty)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        remainingSessions.toString(),
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${member['member_first_name']}',
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMemberButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AnimatedInkWell(
        onTap: _showAddMemberModal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF6EB6FF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF6EB6FF),
                size: 30,
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
      ),
    );
  }

  Widget _buildMembersProgressCard() {
    return CustomCard(
      title: "Members' Progress",
      titleColor: Colors.black,
      titleFontSize: 18,
      trailing: AnimatedInkWell(
        onTap: () {
          // TODO: Navigate to detailed progress screen
        },
        child:
            const Icon(Icons.arrow_forward, color: Color(0xFF6EB6FF), size: 24),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressItem(
                  'Active Members', '${_members.length}', Icons.group),
              _buildProgressItem('Sessions Today', '5', Icons.today),
              _buildProgressItem('Avg. Progress', '75%', Icons.trending_up),
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
        Icon(icon, color: const Color(0xFF6EB6FF), size: 24),
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

  Widget _buildStartSessionButton() {
    return AnimatedInkWell(
      onTap: () {
        final apiService = Provider.of<ApiService>(context, listen: false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TrainerWorkoutInitScreen(apiService: apiService),
          ),
        );
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

  void _showDeleteMenu(
      BuildContext context, dynamic member, Offset tapPosition) {
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
      await apiService.removeTrainerMemberMapping(member['uid']);
      await _fetchMembers();
      _showSuccessDialog(context, 'Member removed successfully');
    } catch (e) {
      _showErrorDialog(context, 'Failed to remove member: $e');
    }
  }

  void _showAddMemberModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        final TextEditingController sessionsController =
            TextEditingController();

        return CustomModal(
          title: 'Add New Member',
          icon: Icons.person_add,
          theme: CustomModalTheme.blue,
          content: Column(
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
                  prefixIcon: const Icon(Icons.fitness_center,
                      color: Color(0xFF6EB6FF)),
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
              onPressed: () {
                Navigator.of(context).pop();
                _addMember(
                    emailController.text, int.parse(sessionsController.text));
              },
              isDefaultAction: true,
            ),
          ],
        );
      },
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
                  _showErrorDialog(
                      context, 'An error occurred. Please try again.');
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
      targetScreen: const TrainerProfileScreen(),
    ),
  ];
}
