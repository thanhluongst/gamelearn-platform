import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnswerOption extends StatelessWidget {
  final String label;
  final String content;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isEnabled;
  final VoidCallback onTap;
  final Color color;
  final IconData? icon;

  const AnswerOption({
    super.key,
    required this.label,
    required this.content,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isEnabled,
    required this.onTap,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = color;
    Color borderColor = color;
    Color textColor = Colors.white;

    if (isCorrect) {
      bgColor = const Color(0xFF43E97B);
      borderColor = const Color(0xFF43E97B);
    } else if (isWrong) {
      bgColor = const Color(0xFFFF4D6D);
      borderColor = const Color(0xFFFF4D6D);
    } else if (!isSelected) {
      bgColor = Colors.white;
      textColor = color;
    }

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isEnabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Label circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected || isCorrect || isWrong
                          ? Colors.white24
                          : color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: icon != null
                          ? Icon(icon, color: isSelected ? Colors.white : color, size: 18)
                          : Text(
                              label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : color,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      content,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCorrect)
                    const Icon(Icons.check_circle, color: Colors.white, size: 20)
                        .animate()
                        .scale(duration: 300.ms),
                  if (isWrong)
                    const Icon(Icons.cancel, color: Colors.white, size: 20)
                        .animate()
                        .scale(duration: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
