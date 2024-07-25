import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final userInfo = await apiService.getMemberInfo();
      setState(() {
        _userInfo = userInfo;
      });
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'User';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showUserInfoDialog(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF4CD964),
                child: Text(
                  'Welcome,\n$firstName',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // ... rest of the build method remains the same
          ],
        ),
      ),
    );
  }

  void _showUserInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Information'),
          content: _userInfo == null
              ? const CircularProgressIndicator()
              : Text(
                  'UID: ${_userInfo!['uid'] ?? 'Unknown'}\n'
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
    return Card(
      elevation: 4,
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
              color: Colors.grey[200],
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

  // TODO: view three most recent sessions
  Widget _buildRecentSessionsCard() {
    return Card(
      elevation: 4,
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
            _buildSessionItem('1', Colors.blue, '2024.02.01', 'PT Session with Jane'),
            _buildSessionItem('2', Colors.green, '2024.01.31', 'Individual Session'),
            _buildSessionItem('3', Colors.blue, '2024.01.30', 'PT Session with Jane'),
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

  Widget _buildSessionItem(String number, Color color, String date, String title) {
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
                style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 12)),
                Text(title, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildStartSessionButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement start new session functionality
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        'Start new Session',
        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
      currentIndex: 1,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
    );
  }
}