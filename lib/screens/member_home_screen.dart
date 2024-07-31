import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/animated_inkwell.dart';
import 'all_sessions_screen.dart';
import 'member_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final firstName = _userInfo?['first_name'] ?? 'User';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedInkWell(
            onTap: () => _showUserInfoDialog(context),
            splashColor: Colors.white.withOpacity(0.3),
            child: Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF4CD964),
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
                _buildRecordsCard(),
                const SizedBox(height: 20),
                _buildRecentSessionsCard(),
                const SizedBox(height: 20),
                _buildStartSessionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUserInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Information'),
          content: Text('UID: ${_userInfo!['uid'] ?? 'Unknown'}\n'
              'Email: ${_userInfo!['email'] ?? 'Unknown'}\n'
              'Role: ${_userInfo!['role'] ?? 'Unknown'}'),
          actions: <Widget>[
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
                _fetchUserInfo();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordsCard() {
    return AnimatedInkWell(
      onTap: () {
        // TODO: Implement view all functionality
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
      ),
    );
  }

  Widget _buildRecentSessionsCard() {
    return AnimatedInkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllSessionsScreen()),
        );
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

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Navigate to menu screen
        // TODO: Implement menu screen navigation
        break;
      case 1:
        // Stay on home screen
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }
}
