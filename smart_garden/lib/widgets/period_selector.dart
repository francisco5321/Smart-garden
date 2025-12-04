import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Color accentColor;
  final Function(String) onPeriodSelected;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.accentColor,
    required this.onPeriodSelected,
  });

  static const List<String> periods = ['1h', '6h', '24h', '7d'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodSelected(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF2D3436).withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                  child: Text(
                    period,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}