import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomDialogTheme { blue, red, green }

class CustomDialog extends StatelessWidget {
  final CustomDialogTheme theme;
  final IconData icon;
  final String title;
  final Widget content;
  final List<DialogAction> actions;
  final String? infoTooltipContent;

  const CustomDialog({
    super.key,
    this.theme = CustomDialogTheme.blue,
    required this.icon,
    required this.title,
    required this.content,
    this.actions = const [],
    this.infoTooltipContent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconAndTitle(context),
          const SizedBox(height: 16),
          content,
          const SizedBox(height: 24),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildIconAndTitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: _getThemeColor(),
          size: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _getThemeColor(),
            ),
          ),
        ),
        if (infoTooltipContent != null)
          IconButton(
            icon: Icon(Icons.info_outline, color: _getThemeColor()),
            onPressed: () => _showInfoTooltip(context),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ElevatedButton(
            onPressed: action.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: action.isDefaultAction ? _getThemeColor() : null,
            ),
            child: Text(
              action.text,
              style: TextStyle(
                color: action.isDefaultAction ? Colors.white : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getThemeColor() {
    switch (theme) {
      case CustomDialogTheme.blue:
        return Colors.blue;
      case CustomDialogTheme.red:
        return Colors.red;
      case CustomDialogTheme.green:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  void _showInfoTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.grey[50],
          title: Row(
            children: [
              Icon(Icons.info_outline, color: _getThemeColor(), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Additional Information',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: _getThemeColor(),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildContentWidgets(infoTooltipContent!),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Got it! 👍',
                style: GoogleFonts.poppins(
                  color: _getThemeColor(),
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
  }

  List<Widget> _buildContentWidgets(String content) {
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
                  style: TextStyle(fontWeight: FontWeight.w600, color: _getThemeColor()),
                );
              }
            }).toList(),
          ),
        ),
      );
    }).toList();
  }
}

class DialogAction {
  final String text;
  final VoidCallback onPressed;
  final bool isDefaultAction;

  const DialogAction({
    required this.text,
    required this.onPressed,
    this.isDefaultAction = false,
  });
}