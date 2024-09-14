import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../services/auth_service.dart';
import '../widgets/background.dart';
import '../widgets/animated_inkwell.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_modal.dart';
import '../widgets/profile_header.dart';
import '../widgets/custom_card.dart';
import 'update_trainer_personal_info_screen.dart';
import 'trainer_home_screen.dart';
import 'login_screen.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  _TrainerProfileScreenState createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
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
      final userInfo = await apiService.getTrainerInfo();
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user info: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshProfile() {
    _fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(
            height: MediaQuery.of(context).size.height,
            colors: const [Color(0xFF6EB6FF), Colors.white],
            stops: const [0.0, 0.3],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            heroTag: 'background_top',
          ),
          SafeArea(
            child: _isLoading ? _buildLoadingIndicator() : _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: _navItems,
        currentIndex: 2,
        onIndexChanged: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const TrainerHomeScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6EB6FF)),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 3, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: GoogleFonts.lato(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                ProfileHeaderWidget(
                  firstName: _userInfo?['first_name'] ?? '',
                  lastName: _userInfo?['last_name'] ?? '',
                  email: _userInfo?['email'] ?? '',
                  membershipType: 'Trainer',
                  onEditPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateTrainerPersonalInfoScreen(
                          userInfo: _userInfo,
                        ),
                      ),
                    ).then((_) => _refreshProfile());
                  },
                  personalInfo: {
                    'specialization': _userInfo?['specialization'] ?? 'Not set',
                    'experience': _userInfo?['experience'] ?? 'Not set',
                  },
                  useMetric: true, // Added useMetric parameter
                  cardColor: const Color(0xFF2196F3),
                  backContentKeys: const ['specialization', 'experience'],
                ),
                const SizedBox(height: 24),
                _buildExperienceCard(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceCard() {
    return CustomCard(
      title: 'Professional Experience',
      titleColor: Colors.black,
      titleFontSize: 21,
      children: [
        _buildInfoItem(
          Icons.school,
          'Specialization',
          _userInfo?['specialization'] ?? 'Not set',
        ),
        _buildInfoItem(
          Icons.work,
          'Years of Experience',
          '${_userInfo?['experience'] ?? 'Not set'} years',
        ),
        _buildInfoItem(
          Icons.star,
          'Rating',
          '${_userInfo?['rating'] ?? 'Not rated'} / 5.0',
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6EB6FF), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
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
  }

  Widget _buildLogoutButton() {
    return AnimatedInkWell(
      onTap: _showLogoutConfirmation,
      splashColor: Colors.red.withOpacity(0.3),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: GoogleFonts.lato(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showCustomModal(
      context: context,
      title: 'Log Out',
      theme: CustomModalTheme.red,
      icon: Icons.exit_to_app,
      content: Text(
        'Are you sure you want to log out?',
        style: GoogleFonts.lato(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: [
        CustomModalAction(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomModalAction(
          text: 'Log Out',
          isDefaultAction: true,
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  void _handleLogout() async {
    Navigator.of(context).pop(); // Close the modal
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
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
