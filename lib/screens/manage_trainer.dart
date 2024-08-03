import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../widgets/custom_modal.dart';
import '../widgets/background.dart';
import '../widgets/animated_inkwell.dart';
import 'package:shimmer/shimmer.dart';

class ManageTrainerScreen extends StatefulWidget {
  const ManageTrainerScreen({super.key});

  @override
  _ManageTrainerScreenState createState() => _ManageTrainerScreenState();
}

class _ManageTrainerScreenState extends State<ManageTrainerScreen> {
  Map<String, dynamic>? _currentTrainer;
  int _remainingSessions = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrainerInfo();
  }

  Future<void> _loadTrainerInfo() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final mappings = await apiService.getMyMappings();
      if (mappings.isNotEmpty) {
        _currentTrainer = mappings.first;
        _remainingSessions = await apiService.getRemainingSessionsForMember(_currentTrainer!['uid']);
      } else {
        _currentTrainer = null;
        _remainingSessions = 0;
      }
    } catch (e) {
      print('Error loading trainer info: $e');
      _currentTrainer = null;
      _remainingSessions = 0;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(
            height: MediaQuery.of(context).size.height,
            colors: const [Color(0xFF4CD964), Colors.white],
            stops: const [0.0, 0.3],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            heroTag: 'background_top',
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    minHeight: 60,
                    maxHeight: 100,
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Text(
                              'Manage Trainer',
                              style: GoogleFonts.lato(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  pinned: true,
                ),
                CupertinoSliverRefreshControl(
                  onRefresh: _loadTrainerInfo,
                ),
                SliverToBoxAdapter(
                  child: _isLoading
                      ? _buildSkeletonUI()
                      : _buildContent(),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _currentTrainer != null
              ? _buildTrainerCard()
              : _buildAddTrainerCard(),
          const SizedBox(height: 24),
          if (_currentTrainer != null) _buildRemainingSessions(),
        ],
      ),
    );
  }

  Widget _buildTrainerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CD964),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${_currentTrainer!['trainer_first_name'][0]}${_currentTrainer!['trainer_last_name'][0]}',
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Trainer',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currentTrainer!['trainer_first_name']} ${_currentTrainer!['trainer_last_name']}',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedInkWell(
              onTap: _showRequestMoreSessionsModal,
              splashColor: const Color(0xFF4CD964).withOpacity(0.3),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CD964),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Request More Sessions',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _showRemoveTrainerConfirmation,
              child: Text(
                'Remove Trainer',
                style: GoogleFonts.lato(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTrainerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CD964).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.person_add, size: 40, color: Color(0xFF4CD964)),
            ),
            const SizedBox(height: 24),
            Text(
              'No Trainer Assigned',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a trainer to get started on your fitness journey!',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedInkWell(
              onTap: _showAddTrainerModal,
              splashColor: const Color(0xFF4CD964).withOpacity(0.3),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CD964),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Add Trainer',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingSessions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remaining Sessions',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_remainingSessions',
                  style: GoogleFonts.lato(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CD964),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Sessions Left',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRemainingSessionsColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRemainingSessionsStatus(),
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getRemainingSessionsColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRemainingSessionsStatus() {
    if (_remainingSessions > 5) return 'Good to go!';
    if (_remainingSessions > 0) return 'Running low';
    return 'Time to renew!';
  }

  Color _getRemainingSessionsColor() {
    if (_remainingSessions > 5) return Colors.green;
    if (_remainingSessions > 0) return Colors.orange;
    return Colors.red;
  }

  void _showAddTrainerModal() {
    String trainerEmail = '';
    String initialSessions = '';

    showCustomModal(
      context: context,
      title: 'Add Your Trainer',
      theme: CustomModalTheme.green,
      icon: CupertinoIcons.person_add,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoTextField(
            placeholder: 'Trainer Email',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            onChanged: (value) => trainerEmail = value,
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            placeholder: 'Initial Sessions',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => initialSessions = value,
          ),
        ],
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
            Navigator.of(context).pop();
            if (trainerEmail.isNotEmpty && initialSessions.isNotEmpty) {
              await _addTrainer(trainerEmail, int.parse(initialSessions));
            }
          },
        ),
      ],
    );
  }
  
  Future<void> _addTrainer(String email, int sessions) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.requestTrainerMemberMapping(email, sessions);
      _showSuccessDialog('Trainer request sent successfully');
      await _loadTrainerInfo();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showRemoveTrainerConfirmation() {
    showCustomModal(
      context: context,
      title: 'Remove Trainer',
      theme: CustomModalTheme.red,
      icon: CupertinoIcons.exclamationmark_triangle,
      content: Text(
        'Are you sure you want to remove your current trainer? This action cannot be undone.',
        style: GoogleFonts.lato(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: [
        CustomModalAction(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomModalAction(
          text: 'Remove',
          isDefaultAction: true,
          onPressed: () async {
            Navigator.of(context).pop();
            await _removeTrainer();
          },
        ),
      ],
    );
  }

  Future<void> _removeTrainer() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.removeTrainerMemberMapping(_currentTrainer!['trainer_email']);
      _showSuccessDialog('Trainer removed successfully');
      await _loadTrainerInfo();
    } catch (e) {
      _showErrorDialog('Failed to remove trainer: $e');
    }
  }

  void _showRequestMoreSessionsModal() {
    int additionalSessions = 0;

    showCustomModal(
      context: context,
      title: 'Request More Sessions',
      theme: CustomModalTheme.green,
      icon: CupertinoIcons.add_circled,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How many additional sessions would you like to request?',
            style: GoogleFonts.lato(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            placeholder: 'Number of sessions',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => additionalSessions = int.tryParse(value) ?? 0,
          ),
        ],
      ),
      actions: [
        CustomModalAction(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomModalAction(
          text: 'Request',
          isDefaultAction: true,
          onPressed: () async {
            Navigator.of(context).pop();
            if (additionalSessions > 0) {
              await _requestMoreSessions(additionalSessions);
            }
          },
        ),
      ],
    );
  }

  Future<void> _requestMoreSessions(int additionalSessions) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.requestMoreSessions(_currentTrainer!['uid'], additionalSessions);
      _showSuccessDialog('Session request sent successfully');
      await _loadTrainerInfo();
    } catch (e) {
      _showErrorDialog('Failed to request more sessions: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showCustomModal(
      context: context,
      title: 'Success',
      theme: CustomModalTheme.green,
      icon: CupertinoIcons.check_mark_circled,
      content: Text(
        message,
        style: GoogleFonts.lato(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: [
        CustomModalAction(
          text: 'OK',
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showCustomModal(
      context: context,
      title: 'Error',
      theme: CustomModalTheme.red,
      icon: CupertinoIcons.exclamationmark_circle,
      content: Text(
        message,
        style: GoogleFonts.lato(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: [
        CustomModalAction(
          text: 'OK',
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}