import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeaderWidget extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String membershipType;
  final VoidCallback onEditPressed;
  final Map<String, dynamic> personalInfo;
  final bool useMetric;
  final IconData backgroundIcon1;
  final IconData backgroundIcon2;
  final Color cardColor;
  final List<String> backContentKeys;

  const ProfileHeaderWidget({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.membershipType,
    required this.onEditPressed,
    required this.personalInfo,
    required this.useMetric,
    this.backgroundIcon1 = Icons.fitness_center,
    this.backgroundIcon2 = Icons.directions_run,
    required this.cardColor,
    this.backContentKeys = const ['age', 'height', 'weight'],
  });

  @override
  _ProfileHeaderWidgetState createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> with TickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _lightSourceController;
  late Animation<double> _lightSourceAnimation;
  late List<Color> _cardGradientColors;
  late AnimationController _tiltController;
  late Animation<Offset> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _lightSourceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _lightSourceAnimation = CurvedAnimation(
      parent: _lightSourceController,
      curve: Curves.easeInOut,
    );

    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tiltAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0.05),
    ).animate(CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut));

    _cardGradientColors = _generateGradientColors(widget.cardColor);
  }

  @override
  void didUpdateWidget(ProfileHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cardColor != widget.cardColor) {
      _cardGradientColors = _generateGradientColors(widget.cardColor);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _lightSourceController.dispose();
    _tiltController.dispose();
    super.dispose();
  }

  List<Color> _generateGradientColors(Color baseColor) {
    final hslColor = HSLColor.fromColor(baseColor);
    return [
      baseColor,
      hslColor.withLightness((hslColor.lightness + 0.1).clamp(0.0, 1.0)).toColor(),
      hslColor.withLightness((hslColor.lightness + 0.2).clamp(0.0, 1.0)).toColor(),
    ];
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
      if (_isFlipped) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      onPanUpdate: (details) {
        setState(() {
          _tiltController.value += details.delta.dx / 100;
          _tiltController.value += details.delta.dy / 100;
          _tiltController.value = _tiltController.value.clamp(0.0, 1.0);
        });
      },
      onPanEnd: (_) {
        _tiltController.animateTo(0.5, curve: Curves.easeOutBack);
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: angle < pi / 2 ? _buildFrontCard() : _buildBackCard(),
          );
        },
      ),
    );
  }

  Widget _buildCard(Widget content) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: AnimatedBuilder(
        animation: Listenable.merge([_lightSourceAnimation, _tiltAnimation]),
        builder: (context, child) {
          final t = _lightSourceAnimation.value;
          final tilt = _tiltAnimation.value;
          final gradientStops = _calculateGradientStops(t);
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(tilt.dy * 0.1)
              ..rotateY(tilt.dx * 0.1),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    _buildCardBackground(gradientStops),
                    _buildMetalTexture(),
                    _buildEdgeHighlight(),
                    content,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBackground(List<GradientStop> gradientStops) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: gradientStops.map((stop) => stop.position).toList(),
          colors: gradientStops.map((stop) => stop.color).toList(),
        ),
      ),
    );
  }

  Widget _buildMetalTexture() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.3,
        child: Image.asset(
          'assets/metal_texture.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget _buildEdgeHighlight() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.transparent,
              Colors.transparent,
              Colors.white.withOpacity(0.3),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return _buildCard(_buildFrontCardContent());
  }

  Widget _buildBackCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: _buildCard(_buildBackCardContent()),
    );
  }

  Widget _buildFrontCardContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            top: -5,
            right: -5,
            child: Icon(
              widget.backgroundIcon1,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: -10,
            left: -10,
            child: Icon(
              widget.backgroundIcon2,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEmbossedText('MEMBERSHIP', 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmbossedText('${widget.firstName} ${widget.lastName}', 24),
                  const SizedBox(height: 4),
                  _buildEmbossedText(widget.email, 14, opacity: 0.8),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEmbossedText(widget.membershipType.toUpperCase(), 16),
                  _buildFlipHint(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildEmbossedText(String text, double fontSize, {double opacity = 1.0}) {
    return Stack(
      children: [
        // Shadow layer
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = Colors.black.withOpacity(opacity * 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          ),
        ),
        // Main text layer
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(opacity),
          ),
        ),
        // Highlight layer
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(opacity * 0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
          ),
        ),
      ],
    );
  }

  Widget _buildBackCardContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEmbossedText('Personal Info', 20),
              _buildEditButton(),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.backContentKeys.map((key) => _buildPersonalInfoItem(key)),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return InkWell(
      onTap: widget.onEditPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.edit,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Edit',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlipHint() {
    return Row(
      children: [
        Text(
          'Tap to flip',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.flip,
          size: 16,
          color: Colors.white.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoItem(String key) {
    String label = key.capitalize();
    String value = _formatMeasurement(widget.personalInfo[key], key);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildEmbossedText(label, 16, opacity: 0.7),
          _buildEmbossedText(value, 16),
        ],
      ),
    );
  }

  String _formatMeasurement(dynamic value, String key) {
    if (value == null || value == '') {
      return 'Not set';
    }
    switch (key) {
      case 'age':
        return '$value years';
      case 'height':
        return widget.useMetric ? '$value cm' : '${(value / 2.54).toStringAsFixed(1)} in';
      case 'weight':
        return widget.useMetric ? '$value kg' : '${(value * 2.20462).toStringAsFixed(1)} lbs';
      default:
        return value.toString();
    }
  }

  List<GradientStop> _calculateGradientStops(double t) {
    const numStops = 30;
    final stops = <GradientStop>[];
    const lightWidth = 0.6;  // Increased from 0.4 for a broader light effect

    final highlightPosition = (t * 2 - 1).abs();
    final highlightIntensity = (1 - highlightPosition).clamp(0.0, 1.0) * 0.4;  // Increased from 0.3 for more intense highlight

for (int i = 0; i < numStops; i++) {
      final position = i / (numStops - 1);
      
      final lightCenter = Offset(t * 1.6 - 0.3, t * 1.6 - 0.3);  // Adjusted for smoother movement
      final distanceFromLight = (Offset(position, position) - lightCenter).distance;
      final colorT = (distanceFromLight / (lightWidth / 2)).clamp(0.0, 1.0);

      final easeColorT = Curves.easeInOut.transform(colorT);
      
      final color = Color.lerp(
        _cardGradientColors[2],
        _cardGradientColors[0],
        easeColorT
      )!.withOpacity(1.0 - highlightIntensity * 0.7);  // Adjusted for more subtle effect

      stops.add(GradientStop(position, color));
    }

    // Add highlight effect
    stops.add(GradientStop(highlightPosition, Colors.white.withOpacity(highlightIntensity)));

    return stops;
  }
}

class GradientStop {
  final double position;
  final Color color;

  GradientStop(this.position, this.color);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}