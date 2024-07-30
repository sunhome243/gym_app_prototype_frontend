import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoTooltip extends StatelessWidget {
  final String title;
  final String content;

  const InfoTooltip({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.info_outline, color: Colors.blue[700]),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.grey[50],
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildContentWidgets(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Got it! 👍',
                    style: GoogleFonts.poppins(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }


  List<Widget> _buildContentWidgets() {
    final paragraphs = content.split('\n\n');
    return paragraphs.map((paragraph) {
      final parts = paragraph.split('**');
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[800], height: 1.5),
            children: parts.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;
              if (index.isEven) {
                return TextSpan(text: text);
              } else {
                return TextSpan(
                  text: text,
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue[800]),
                );
              }
            }).toList(),
          ),
        ),
      );
    }).toList();
  }
}