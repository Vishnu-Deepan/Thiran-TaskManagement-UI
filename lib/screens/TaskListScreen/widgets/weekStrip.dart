import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekStrip extends StatefulWidget {
  final DateTime selected;
  final void Function(DateTime) onDaySelected;

  const WeekStrip({super.key, required this.selected, required this.onDaySelected});

  @override
  _WeekStripState createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  late DateTime _currentStartDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentStartDate = widget.selected; // Initialize with the selected date
    _selectedDate = widget.selected; // Set the selected date initially
  }

  // Calculate the next four days from a given date
  List<DateTime> _getDays(DateTime startDate) {
    return List.generate(4, (i) => startDate.add(Duration(days: i)));
  }

  // Move to the previous set of 4 days
  void _moveToPreviousDays() {
    setState(() {
      _currentStartDate = _currentStartDate.subtract(Duration(days: 4));
      _selectedDate = _selectedDate.subtract(Duration(days: 4));
    });
    widget.onDaySelected(_selectedDate);
  }

  // Move to the next set of 4 days
  void _moveToNextDays() {
    setState(() {
      _currentStartDate = _currentStartDate.add(Duration(days: 4));
      _selectedDate = _selectedDate.add(Duration(days: 4));
    });
    widget.onDaySelected(_selectedDate);
  }

  // Reset to today's date
  void _moveToToday() {
    setState(() {
      _currentStartDate = DateTime.now();
      _selectedDate = DateTime.now();
    });
    widget.onDaySelected(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDays(_currentStartDate);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Buttons Row (Top)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prev Button
            _buildNeumorphicButton(
              icon: Icons.arrow_left,
              onPressed: _moveToPreviousDays,
              size: 28,
            ),

            SizedBox(width: 16),  // Space between buttons

            // Today Button with Text
            _buildNeumorphicButtonWithText(
              icon: Icons.today,
              text: "TODAY",
              onPressed: _moveToToday,
              size: 28,
              iconColor: Colors.indigo,  // Color for "Today" button
            ),

            SizedBox(width: 16),  // Space between buttons

            // Next Button
            _buildNeumorphicButton(
              icon: Icons.arrow_right,
              onPressed: _moveToNextDays,
              size: 28,
            ),
          ],
        ),

        SizedBox(height: 16),  // Space between the two rows

        // Days Row (Bottom)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: days.map((d) {
            final isSelected = DateFormat('yyyy-MM-dd').format(d) == DateFormat('yyyy-MM-dd').format(_selectedDate);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = d;
                  });
                  widget.onDaySelected(d);
                },
                child: _buildNeumorphicDayCell(d, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Function to create neumorphic styled buttons (Prev and Next)
  Widget _buildNeumorphicButton({
    required IconData icon,
    required void Function() onPressed,
    double size = 28, // Default size
    Color iconColor = Colors.deepPurpleAccent, // Default icon color
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50, // Blue theme for button background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.6), // Light shadow for the raised effect
            offset: Offset(-1, -1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Colors.indigo.shade600.withOpacity(0.3), // Dark shadow to simulate depth
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor), // Icon color
        onPressed: onPressed,
        iconSize: size,
      ),
    );
  }

  // Function to create neumorphic button with both Icon and Text (for "Today")
  Widget _buildNeumorphicButtonWithText({
    required IconData icon,
    required String text,
    required void Function() onPressed,
    double size = 28,
    Color iconColor = Colors.green, // Icon color for "Today"
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50, // Blue theme for button background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            offset: Offset(-1, -1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Colors.indigo.shade600.withOpacity(0.3),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: size),
        label: Text(
          text,
          style: TextStyle(color: iconColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Function to build neumorphic day cell
  Widget _buildNeumorphicDayCell(DateTime day, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.indigo.shade400 : Colors.white, // Light blue background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isSelected) ...[
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              offset: Offset(-1, -1),
              blurRadius: 2,
            ),
            BoxShadow(
              color: Colors.indigo.shade600.withOpacity(0.3),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
          if (isSelected) ...[
            BoxShadow(
              color: Colors.indigo.shade900.withOpacity(0.3),
              offset: Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.indigo.shade500.withOpacity(0.3),
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('EEE').format(day),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.indigo.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${day.day}',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.indigo.shade800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
