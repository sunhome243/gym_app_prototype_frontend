import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../services/schemas.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/background.dart';
import 'package:intl/intl.dart';

class SessionSummaryScreen extends StatefulWidget {
  final int sessionId;
  final String memberName;

  const SessionSummaryScreen({
    Key? key, 
    required this.sessionId, 
    required this.memberName
  }) : super(key: key);

  @override
  _SessionSummaryScreenState createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  late Future<SessionDetail> _sessionDetailFuture;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _sessionDetailFuture = apiService.getSessionDetail(widget.sessionId);
  }

  Color _getThemeColor(SessionDetail sessionDetail) {
    if (sessionDetail.is_pt) {
      return const Color(0xFF6EB6FF);
    }
    switch (sessionDetail.session_type_id) {
      case 1:
        return const Color(0xFF00CED1); // AI
      case 2:
        return const Color(0xFFF39C12); // Quest
      case 3:
        return const Color(0xFF6F42C1); // Custom
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<SessionDetail>(
        future: _sessionDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final sessionDetail = snapshot.data!;
          final themeColor = _getThemeColor(sessionDetail);

          return Stack(
            children: [
              Background(
                height: MediaQuery.of(context).size.height,
                colors: [themeColor, Colors.white],
                stops: const [0.0, 0.3],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                heroTag: 'background_top',
              ),
              SafeArea(
                child: _buildContent(sessionDetail, themeColor),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(SessionDetail sessionDetail, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              const CustomBackButton(),
              const SizedBox(width: 8),
              Text(
                'Session Summary',
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSessionInfoCard(sessionDetail, themeColor),
                  const SizedBox(height: 16),
                  _buildWorkoutsOverview(sessionDetail, themeColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionInfoCard(SessionDetail sessionDetail, Color themeColor) {
    String formattedDate = DateFormat('MMMM d, yyyy - HH:mm').format(sessionDetail.workout_date);
    
    return CustomCard(
      title: 'Session Information',
      titleColor: themeColor,
      titleFontSize: 18,
      children: [
        _buildInfoRow('Date', formattedDate),
        _buildInfoRow('Type', sessionDetail.session_type),
        _buildInfoRow('Member', widget.memberName),
        if (sessionDetail.is_pt && sessionDetail.trainer_name != null)
          _buildInfoRow('Trainer', sessionDetail.trainer_name!),
        _buildInfoRow('Total Workouts', sessionDetail.workouts.length.toString()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsOverview(SessionDetail sessionDetail, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workouts',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
        ),
        const SizedBox(height: 8),
        ...sessionDetail.workouts.map((workout) => _buildWorkoutCard(workout, themeColor)).toList(),
      ],
    );
  }

  Widget _buildWorkoutCard(WorkoutDetail workout, Color themeColor) {
    return CustomCard(
      title: workout.workout_name,
      titleColor: themeColor,
      titleFontSize: 18,
      children: [
        Text(
          'Part: ${workout.workout_part}',
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        ...workout.sets.map((set) => _buildSetRow(set)).toList(),
      ],
    );
  }

  Widget _buildSetRow(SetDetail set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Set ${set.set_num}',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            '${set.weight} kg x ${set.reps} reps',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          Text(
            'Rest: ${set.rest_time}s',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}