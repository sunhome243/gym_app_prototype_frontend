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
import 'session_summary_screen.dart';

class TrainerMemberAllSessionsScreen extends StatefulWidget {
  const TrainerMemberAllSessionsScreen(
      {super.key, required this.refreshHomeScreen});

  final Function refreshHomeScreen;

  @override
  _TrainerMemberAllSessionsScreenState createState() =>
      _TrainerMemberAllSessionsScreenState();
}

class _TrainerMemberAllSessionsScreenState
    extends State<TrainerMemberAllSessionsScreen> {
  List<SessionWithSets> _sessions = [];
  final Map<String, String> _memberNames = {};
  bool _isLoading = true;
  String _errorMessage = '';
  String _sortBy = 'date';
  bool _sortAscending = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
      final sessions = await apiService.getTrainerMemberSessions();
      final memberUids = sessions.map((s) => s.member_uid).toSet().toList();

      // Fetch member names
      for (var uid in memberUids) {
        final memberInfo = await apiService.getMemberInfoByUid(uid);
        _memberNames[uid] =
            '${memberInfo['first_name']} ${memberInfo['last_name']}';
      }

      setState(() {
        _sessions = sessions;
        _sortAndFilterSessions();
        _isLoading = false;
      });
      _updateSessionsToday();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load sessions: ${e.toString()}';
      });
    }
  }

  void _sortAndFilterSessions() {
    _sessions = _sessions.where((session) {
      final memberName = _memberNames[session.member_uid]?.toLowerCase() ?? '';
      final searchTerms = _searchQuery.toLowerCase().split(' ');
      return searchTerms.every((term) => memberName.contains(term));
    }).toList();

    _sessions.sort((a, b) {
      switch (_sortBy) {
        case 'date':
          return _sortAscending
              ? a.workout_date.compareTo(b.workout_date)
              : b.workout_date.compareTo(a.workout_date);
        case 'name':
          return _sortAscending
              ? (_memberNames[a.member_uid] ?? '')
                  .compareTo(_memberNames[b.member_uid] ?? '')
              : (_memberNames[b.member_uid] ?? '')
                  .compareTo(_memberNames[a.member_uid] ?? '');
        case 'type':
          return _sortAscending
              ? _getWorkoutType(a).compareTo(_getWorkoutType(b))
              : _getWorkoutType(b).compareTo(_getWorkoutType(a));
        default:
          return 0;
      }
    });
  }

  String _getWorkoutType(SessionWithSets session) {
    if (session.is_pt) {
      return 'PT Session';
    } else if (session.session_type_id == 1) {
      return 'AI Workout';
    } else {
      return 'Custom Workout';
    }
  }

  void _updateSessionsToday() {
    final today = DateTime.now().toLocal().toString().split(' ')[0];
    final sessionsToday = _sessions
        .where((session) => session.workout_date.startsWith(today))
        .length;
    widget.refreshHomeScreen(sessionsToday);
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
                        'All Member Sessions',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildSearchBar(),
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

  Widget _buildSearchBar() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _sortAndFilterSessions();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search member',
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          hintStyle: GoogleFonts.lato(color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        style: GoogleFonts.lato(color: Colors.white),
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
            DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
            DropdownMenuItem(value: 'type', child: Text('Sort by Type')),
          ],
          onChanged: (value) {
            setState(() {
              _sortBy = value!;
              _sortAndFilterSessions();
            });
          },
        ),
        IconButton(
          icon:
              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: () {
            setState(() {
              _sortAscending = !_sortAscending;
              _sortAndFilterSessions();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSessionCard(SessionWithSets session) {
    IconData iconData;
    Color iconColor;
    String sessionType = _getWorkoutType(session);

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

    String formattedDate = DateFormat('yyyy-MM-dd HH:mm')
        .format(DateTime.parse(session.workout_date));

    return CustomCard(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionSummaryScreen(
                sessionId: session.session_id,
                memberName:
                    _memberNames[session.member_uid] ?? 'Unknown Member',
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          _memberNames[session.member_uid] ?? 'Unknown Member',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sessionType,
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
            Text(
              formattedDate,
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Text(
          '${session.sets.length} sets',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
