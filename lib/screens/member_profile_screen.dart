import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../services/api_services.dart';
import '../services/auth_service.dart';
import '../widgets/animated_inkwell.dart';
import 'member_home_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'login_screen.dart';
import '../widgets/custom_modal.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  _MemberProfileScreenState createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;
  Map<String, dynamic> _userInfo = {};
  List<dynamic> _trainerMappings = [];
  bool _isLoading = true;

  int _selectedIndex = 2;

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadUserInfo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final idToken = await apiService.getIdToken();
      final decodedToken = JwtDecoder.decode(idToken);
      final mappings = await apiService.getMyMappings();

      setState(() {
        _userInfo = {
          'fullName': decodedToken['name'] ?? 'Unknown',
          'email': decodedToken['email'] ?? 'Unknown',
          'uid': decodedToken['sub'] ?? 'Unknown',
        };
        _trainerMappings = mappings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user info: $e');
      setState(() => _isLoading = false);
    }
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _showLogoutConfirmationDialog() {
    showCustomModal(
      context: context,
      title: 'Log Out?',
      theme: CustomModalTheme.red,
      icon: Icons.exit_to_app,
      content: Text(
        'Are you sure you want to log out?',
        style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
      ),
      actions: [
        CustomModalAction(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomModalAction(
          text: 'Log Out',
          isDefaultAction: true,
          onPressed: () async {
            await Provider.of<AuthService>(context, listen: false).signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_userInfo['fullName'] ?? 'Profile',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[400]!, Colors.blue[800]!],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _showLogoutConfirmationDialog,
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildProfileInfo(),
              _buildManageTrainerCard(),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Notifications coming soon!',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ]),
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

  Widget _buildProfileInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: Text('Email',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              subtitle: Text(_userInfo['email'] ?? 'Unknown',
                  style: GoogleFonts.lato()),
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint, color: Colors.blue),
              title: Text('UID',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              subtitle: Text(_userInfo['uid'] ?? 'Unknown',
                  style: GoogleFonts.lato()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageTrainerCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            AnimatedInkWell(
              onTap: _toggleExpand,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Trainer',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                      child: const Icon(Icons.expand_more,
                          color: Colors.blue, size: 28),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child:
              _isExpanded ? _buildTrainerInfo() : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerInfo() {
    if (_trainerMappings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'You don\'t have any trainers yet.',
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddTrainerDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Add Your Trainer!', style: GoogleFonts.lato()),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: _trainerMappings.map((mapping) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Text(
                '${mapping['trainer_first_name'][0]}${mapping['trainer_last_name'][0]}',
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
            ),
            title: Text(
              '${mapping['trainer_first_name']} ${mapping['trainer_last_name']}',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              mapping['status'],
              style: GoogleFonts.lato(
                color: mapping['status'] == 'accepted'
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
            onTap: () {
              // Handle tap on trainer
            },
          );
        }).toList(),
      );
    }
  }

  Future<void> _addTrainer(String email, int sessions) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.requestTrainerMemberMapping(email, sessions);
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showAddTrainerDialog() {
    final formKey = GlobalKey<FormState>();
    String trainerEmail = '';
    String initialSessions = '';

    showCustomModal(
      context: context,
      title: 'Add Your Trainer',
      theme: CustomModalTheme.blue,
      icon: Icons.person_add,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Trainer Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.email, color: Colors.blue),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter trainer\'s email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onSaved: (value) => trainerEmail = value!,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Initial Sessions',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.fitness_center, color: Colors.blue),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter initial sessions';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => initialSessions = value!,
                ),
                const SizedBox(height: 4),
                Padding( // 설명 텍스트에만 왼쪽 패딩 적용
                  padding: const EdgeInsets.only(left: 48), 
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Enter the number of sessions you've contracted with your trainer.",
                      style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        CustomModalAction(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomModalAction(
          text: 'Add Trainer',
          isDefaultAction: true,
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              try {
                await _addTrainer(trainerEmail, int.parse(initialSessions));
                Navigator.of(context).pop();
              } catch (e) {
                _showErrorDialog(e.toString());
              }
            }
          },
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    showCustomModal(
      context: context,
      title: 'Success!',
      theme: CustomModalTheme.green,
      icon: Icons.check_circle_outline,
      content: RichText(
        text: TextSpan(
          style: GoogleFonts.lato(fontSize: 16, color: Colors.black87, height: 1.5),
          children: [
            TextSpan(
              text: 'Connection request sent! \n\n',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            const TextSpan(text: 'What\'s next?\n'),
            TextSpan(
              text: 'Now, sit tight and maybe do a few stretches. Wait for trainer acceptance\n\n',
              style: TextStyle(color: Colors.green[700]),
            ),
          ],
        ),
      ),
      actions: [
        CustomModalAction(
          text: 'Got it!',
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showCustomModal(
      context: context,
      title: 'Oops!',
      theme: CustomModalTheme.red,
      icon: Icons.error_outline,
      content: Text(
        message,
        style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
      ),
      actions: [
        CustomModalAction(
          text: 'Got it!',
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}