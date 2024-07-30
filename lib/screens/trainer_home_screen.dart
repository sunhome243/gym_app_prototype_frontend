import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_services.dart';
import '../widgets/animated_inkwell.dart';
import '../widgets/animated_modal_button.dart';
import 'member_profile_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/custom_modal.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  _TrainerHomeScreenState createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  Map<String, dynamic>? _trainerInfo;
  List<dynamic> _members = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showAddMemberCard = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sessionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTrainerInfo();
    _fetchMembers();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _sessionsController.dispose();
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

  void _showTrainerInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trainer Information'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${_trainerInfo?['first_name']} ${_trainerInfo?['last_name']}'),
              Text('Email: ${_trainerInfo?['email']}'),
              Text('Role: ${_trainerInfo?['role']}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Refresh'),
              onPressed: () {
                Navigator.of(context).pop();
                _fetchTrainerInfo();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchMembers() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final members = await apiService.getMyMappings();
      setState(() {
        _members = members;
      });
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _getSelectedScreen(),
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text('Menu Screen'));
      case 1:
        return _buildContent();
      case 2:
        return const ProfileScreen();
      default:
        return _buildContent();
    }
  }

  Widget _buildMyMembersCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Members',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading 
              ? _buildSkeletonUI()
              : _buildMembersGrid(),
          ],
        ),
      ),
    );
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
    int itemCount = _members.length < 3 ? _members.length + 1 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < _members.length && index < 3) {
          return _buildMemberAvatar(_members[index]);
        } else if (index == _members.length || (index == 3 && _members.length > 3)) {
          return _buildAddMemberButton();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddMemberButton() {
    return AnimatedInkWell(
      onTap: _showAddMemberModal,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              color: Colors.blue,
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
          const SizedBox(height: 8),
          Text(
            'Add',
            style: GoogleFonts.lato(
              fontSize: 14,
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

    return AnimatedInkWell(
      onTap: () {
        if (isPending && !isRequestor) {
          _showApprovalModal(member);
        } else if (member['status'] == 'approved') {
          // TODO: Navigate to profile page
          print('Navigating to profile page');
        }
      },
      onLongPress: () {
        _showDeleteMenu(context, member);
      },
      splashColor: Colors.blue.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'member-avatar-${member['member_email']}',
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              child: Text(
                '${member['member_first_name'][0]}${member['member_last_name'][0]}',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${member['member_first_name']} ${member['member_last_name']}',
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isPending)
            Text(
              isRequestor ? 'Sent' : 'Pending',
              style: GoogleFonts.lato(
                fontSize: 10,
                color: isRequestor ? Colors.blue : Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  void _showDeleteMenu(BuildContext context, dynamic member) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ModernDeleteButton(
            onDelete: () {
              Navigator.pop(context);
              _showDeleteConfirmationModal(member);
            },
          ),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }



Widget _buildContent() {
  final firstName = _trainerInfo?['first_name'] ?? 'Trainer';
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedInkWell(
          onTap: () => _showTrainerInfoDialog(context),
          splashColor: Colors.white.withOpacity(0.3),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue,
            child: Text(
              'Welcome,\n$firstName',
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMyMembersCard(),
              const SizedBox(height: 20),
              _buildMembersProgressCard(),
              const SizedBox(height: 20),
              _buildStartSessionButton(),
            ],
          ),
        ),
      ],
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
          iconColor: Colors.blue,
          content: Column(
            children: [
              _buildAnimatedTextField(
                controller: _emailController,
                label: 'Member Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              _buildAnimatedTextField(
                controller: _sessionsController,
                label: 'Initial Sessions',
                icon: Icons.fitness_center,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.lato(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addMember();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Add Member',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
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
      _showSuccessDialog('Member request sent successfully');
      _emailController.clear();
      _sessionsController.clear();
      setState(() {
        _showAddMemberCard = false;
      });
      _animationController.reverse();
      _fetchMembers(); // Refresh the member list
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('not found')) {
        errorMessage = 'We couldn\'t find a member with that email. Double-check the address and try again!';
      } else if (e.toString().contains('Mapping already exists and is accepted')) {
        errorMessage = 'Great news! You\'re already connected with this member. No need to reconnect. You\'re all set to start training!';
      } else if (e.toString().contains('Mapping already exists and is pending')) {
        errorMessage = 'You\'ve already sent a request to this member. They\'re probably just warming up before accepting. Hang tight!';
      } else {
        errorMessage = 'Whoa, where are we? Can we try that again?';
      }
      _showErrorDialog(errorMessage);
    }
  }

void _showSuccessDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomModal(
        title: 'Success! 🎉',
        icon: Icons.check_circle_outline,
        iconColor: Colors.green[700],
        titleColor: Colors.green[700],
        content: Text(
          message,
          style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
        ),
        actions: [
          TextButton(
            child: Text(
              'Got it!',
              style: GoogleFonts.lato(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomModal(
        title: 'Oops! 🙈',
        icon: Icons.error_outline,
        iconColor: Colors.amber[700],
        titleColor: Colors.amber[700],
        content: Text(
          message,
          style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
        ),
        actions: [
          TextButton(
            child: Text(
              'Got it!',
              style: GoogleFonts.lato(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

void _showDeleteConfirmationModal(dynamic member) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomModal(
        title: 'Remove Member',
        icon: Icons.warning,
        iconColor: Colors.red,
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
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.lato(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiService = Provider.of<ApiService>(context, listen: false);
              await apiService.removeTrainerMemberMapping(member['member_email']);
              Navigator.pop(context);
              _fetchMembers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              'Remove',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

void _showApprovalModal(dynamic member) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomModal(
        title: 'New Member Alert!',
        icon: Icons.person_add,
        iconColor: Colors.blue,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${member['member_first_name']} wants to join your fitness squad!',
              style: GoogleFonts.lato(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Ready to welcome them to the gains train?',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Now', style: GoogleFonts.lato(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiService = Provider.of<ApiService>(context, listen: false);
              if (member['mapping_id'] != null) {
                await apiService.updateTrainerMemberMappingStatus(member['mapping_id'], 'accepted');
                Navigator.pop(context);
                _fetchMembers();
              } else {
                print('Error: mapping id is null');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('An error occurred. Please try again.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              'Let\'s Go! 💪',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

  Widget _buildMembersProgressCard() {
    return AnimatedInkWell(
      onTap: () {
        // TODO: Implement view all progress functionality
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
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

  Widget _buildCustomBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.menu, 0),
            _buildNavItem(Icons.home, 1),
            _buildNavItem(Icons.person, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 0.8),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}

class ModernDeleteButton extends StatefulWidget {
  final VoidCallback onDelete;

  const ModernDeleteButton({super.key, required this.onDelete});

  @override
  _ModernDeleteButtonState createState() => _ModernDeleteButtonState();
}

class _ModernDeleteButtonState extends State<ModernDeleteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onDelete,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}