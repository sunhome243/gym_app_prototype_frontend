import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../services/schemas.dart';

class AllSessionsScreen extends StatefulWidget {
  const AllSessionsScreen({super.key});

  @override
  _AllSessionsScreenState createState() => _AllSessionsScreenState();
}

class _AllSessionsScreenState extends State<AllSessionsScreen> {
  List<SessionWithSets> _sessions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final sessions = await apiService.getSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching sessions: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load sessions: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSessions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSessions,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchSessions,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    } else if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No sessions found'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchSessions,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return _buildSessionItem(session);
        },
      );
    }
  }

  Widget _buildSessionItem(SessionWithSets session) {
    IconData iconData;
    Color iconColor;
    if (session.is_pt) {
      iconData = Icons.person;
      iconColor = Colors.blue;
    } else if (session.session_type_id == 1) {
      iconData = Icons.auto_awesome;
      iconColor = Colors.purple;
    } else {
      iconData = Icons.fitness_center;
      iconColor = Colors.green;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor,
        child: Icon(iconData, color: Colors.white),
      ),
      title: Text(
        session.is_pt
            ? 'PT Session'
            : session.session_type_id == 1
                ? 'AI Workout'
                : 'Custom Workout',
        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        session.workout_date.toString().split(' ')[0],
        style: GoogleFonts.lato(color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Navigate to session details screen
      },
    );
  }
}