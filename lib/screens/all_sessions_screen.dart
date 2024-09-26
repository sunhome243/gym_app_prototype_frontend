import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_services.dart';
import '../services/schemas.dart';
import '../widgets/custom_card.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/background.dart';
import 'package:shimmer/shimmer.dart';

class AllSessionsScreen extends StatefulWidget {
  const AllSessionsScreen({super.key});

  @override
  _AllSessionsScreenState createState() => _AllSessionsScreenState();
}

class _AllSessionsScreenState extends State<AllSessionsScreen> {
  List<SessionWithSets> _sessions = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _sortBy = 'date';
  bool _sortAscending = false;

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

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final sessions = await apiService.getSessions();
      setState(() {
        _sessions = sessions;
        _sortSessions();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load sessions: ${e.toString()}';
      });
    }
  }

  void _sortSessions() {
    _sessions.sort((a, b) {
      if (_sortBy == 'date') {
        return _sortAscending
            ? a.workout_date.compareTo(b.workout_date)
            : b.workout_date.compareTo(a.workout_date);
      } else {
        return _sortAscending
            ? a.session_type_id.compareTo(b.session_type_id)
            : b.session_type_id.compareTo(a.session_type_id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(
            height: MediaQuery.of(context).size.height,
            colors: const [Color(0xFF3CD687), Colors.white],
            stops: const [0.0, 0.3],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            heroTag: 'background_top',
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      const CustomBackButton(),
                      const SizedBox(width: 8),
                      Text(
                        'All Sessions',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading ? _buildSkeletonUI() : _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonUI() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage.isNotEmpty) {
      return Center(
          child: Text(_errorMessage, style: TextStyle(color: Colors.red)));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSortingOptions(),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              return AnimatedListItem(
                index: index,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildSessionCard(_sessions[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortingOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: _sortBy,
          items: [
            DropdownMenuItem(value: 'date', child: Text('Sort by Date')),
            DropdownMenuItem(value: 'type', child: Text('Sort by Type')),
          ],
          onChanged: (value) {
            setState(() {
              _sortBy = value!;
              _sortSessions();
            });
          },
        ),
        IconButton(
          icon:
              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: () {
            setState(() {
              _sortAscending = !_sortAscending;
              _sortSessions();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSessionCard(SessionWithSets session) {
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

    String formattedDate = DateFormat('yyyy-MM-dd HH:mm')
        .format(DateTime.parse(session.workout_date));

    return CustomCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          sessionType,
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          formattedDate,
          style: GoogleFonts.lato(color: Colors.grey[600]),
        ),
        trailing: Text(
          '${session.sets.length} sets',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        onTap: () {
          // TODO: Navigate to session details screen
        },
      ),
    );
  }
}
