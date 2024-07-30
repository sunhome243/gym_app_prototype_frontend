import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../widgets/info_tooltip.dart';
import '../widgets/animated_inkwell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;
  Map<String, dynamic> _userInfo = {};
  List<dynamic> _trainerMappings = [];
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileCard(),
                  _buildManageTrainerCard(),
                  const SizedBox(height: 20),
                  Text(
                    'Notifications coming soon!',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Hero(
                  tag: 'profile-avatar',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userInfo['fullName'] ?? 'Loading...',
                        style: GoogleFonts.lato(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userInfo['email'] ?? 'Loading...',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'UID: ${_userInfo['uid'] ?? 'Loading...'}',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageTrainerCard() {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(top: 30),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                const SizedBox(height: 40),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    height: _isExpanded ? null : 0,
                    child: _buildTrainerInfo(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 32,
          right: 32,
          child: Hero(
            tag: 'manage-trainer-header',
            child: AnimatedInkWell(
              onTap: _toggleExpand,
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manage Trainer',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                        child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerInfo() {
    if (_trainerMappings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'You don\'t have any trainers yet.',
              style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AnimatedInkWell(
              onTap: _showAddTrainerModal,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Add Your Trainer!',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: _trainerMappings.map((mapping) => AnimatedInkWell(
          onTap: () {
            // Handle tap on trainer item
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.fitness_center, color: Colors.green[800], size: 28),
            ),
            title: Text(
              '${mapping['trainer_first_name']} ${mapping['trainer_last_name']}',
              style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              mapping['status'],
              style: GoogleFonts.lato(
                fontSize: 16,
                color: mapping['status'] == 'accepted' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
          ),
        )).toList(),
      );
    }
  }

  void _showAddTrainerModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AddTrainerModal(onTrainerAdded: _handleTrainerAdded),
        );
      },
    );
  }

  void _handleTrainerAdded() {
    _loadUserInfo();  // Refresh the trainer mappings
  }
}

class AddTrainerModal extends StatefulWidget {
  final Function onTrainerAdded;

  const AddTrainerModal({super.key, required this.onTrainerAdded});

  @override
  _AddTrainerModalState createState() => _AddTrainerModalState();
}

class _AddTrainerModalState extends State<AddTrainerModal> {
  final _formKey = GlobalKey<FormState>();
  String _trainerEmail = '';
  String _initialSessions = '';
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Oops! ',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.amber[700],
                  ),
                ),
                const TextSpan(
                  text: '🙈',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
          content: RichText(
            text: TextSpan(
              style: GoogleFonts.lato(fontSize: 18, color: Colors.black87, height: 1.5),
              children: [
                TextSpan(text: message.substring(0, message.lastIndexOf('.'))),
                const TextSpan(text: ' '),
                TextSpan(
                  text: message.substring(message.lastIndexOf('.') + 1).trim(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ],
            ),
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      final apiService = Provider.of<ApiService>(context, listen: false);
      try {
        await apiService.requestTrainerMemberMapping(_trainerEmail, int.parse(_initialSessions));
        Navigator.pop(context);
        widget.onTrainerAdded();
        _showSuccessDialog(); // 성공 시 성공 메시지 보여주기
      } catch (e) {
        String errorMessage;
        if (e.toString().contains('not found')) {
          errorMessage = 'We couldn\'t find a trainer with that email. 📧 Double-check the address and try again. Let\'s make sure we\'re connecting you with the right fitness guru!';
        } else if (e.toString().contains('Mapping already exists and is accepted')) {
          errorMessage = 'Great news! You\'re already connected with this trainer. 🎉 No need to reconnect. You\'re all set to crush those goals!';
        } else if (e.toString().contains('Mapping already exists and is pending')) {
          errorMessage = 'You\'ve already sent a request to this trainer. 🕒 They\'re probably just warming up before accepting. Hang tight!';
        } else {
          errorMessage = 'An unexpected error occurred. ⚠️ Can we try that again?';
        }
        _showErrorDialog(errorMessage);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'High Five! ✋',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.green[700]),
          ),
          content: Text(
            'You\'ve successfully sent a connection request to your trainer! Now, sit tight and maybe do a few stretches. 🧘‍♂️ Your trainer needs to accept the request before you can start logging those gains. We\'ll let you know when they\'re ready to pump you up! 💪',
            style: GoogleFonts.lato(fontSize: 18, height: 1.5),
          ),
          actions: [
            TextButton(
              child: Text(
                'Awesome!',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Your Trainer 🏋️‍♂️',
              style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Trainer Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.email, color: Colors.blue),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              style: GoogleFonts.lato(fontSize: 16),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter trainer\'s email';
                }
                return null;
              },
              onSaved: (value) => _trainerEmail = value!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Initial Sessions',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      prefixIcon: const Icon(Icons.fitness_center, color: Colors.blue),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    style: GoogleFonts.lato(fontSize: 16),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter initial sessions';
                      }
                      return null;
                    },
                    onSaved: (value) => _initialSessions = value!,
                  ),
                ),
                const InfoTooltip(
                  title: 'Session Guide 💡',
                  content: 'Enter the **number of sessions** you\'ve agreed with your trainer.\n\nThis will be used to **track your progress** and **plan your fitness journey**. Let\'s get those gains! 💪',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: Text(
                          'Request 🚀',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}