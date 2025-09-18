import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekStrip extends StatelessWidget {
  final DateTime selected;
  final void Function(DateTime) onDaySelected;

  const WeekStrip({super.key, required this.selected, required this.onDaySelected});

  List<DateTime> _monToThu(DateTime ref) {
    final weekday = ref.weekday; // 1..7
    final monday = ref.subtract(Duration(days: weekday - 1));
    return List.generate(4, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final days = _monToThu(selected);
    return Row(
      children: days.map((d) {
        final isSelected = DateFormat('yyyy-MM-dd').format(d) == DateFormat('yyyy-MM-dd').format(selected);
        return Expanded(
          child: GestureDetector(
            onTap: () => onDaySelected(d),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigo : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(DateFormat('EEE').format(d),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                  const SizedBox(height: 6),
                  Text('${d.day}', style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
