import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thiran_assessment/models/taskModel.dart';
import 'package:thiran_assessment/screens/CreateTaskScreen/createTaskScreen.dart';
import 'package:thiran_assessment/screens/TaskListScreen/widgets/taskCard.dart';
import 'package:thiran_assessment/screens/TaskListScreen/widgets/weekStrip.dart';
import 'package:thiran_assessment/utils/date_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Design review',
      category: 'Work',
      date: DateTime.now(),
      startTime: TimeOfDay(hour: 10, minute: 0),
      endTime: TimeOfDay(hour: 11, minute: 0),
      description: 'Review screens with product team',
    ),
    Task(
      id: '2',
      title: 'Grocery shopping',
      category: 'Personal',
      date: DateTime.now().add(const Duration(days: 1)),
      startTime: TimeOfDay(hour: 18, minute: 30),
      description: 'Buy veggies and milk',
    ),
    Task(
      id: '3',
      title: 'Workout',
      category: 'Health',
      date: DateTime.now().add(const Duration(days: 2)),
      startTime: TimeOfDay(hour: 7, minute: 0),
      description: 'Gym — legs',
    ),
    Task(
      id: '4',
      title: 'Assignment',
      category: 'Study',
      date: DateTime.now(),
      startTime: TimeOfDay(hour: 10, minute: 0),
      endTime: TimeOfDay(hour: 11, minute: 0),
    ),
  ];

  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _normalizeTasks();
  }

  void _normalizeTasks() {
    _tasks.sort((a, b) {
      final ad = DateTime(a.date.year, a.date.month, a.date.day);
      final bd = DateTime(b.date.year, b.date.month, b.date.day);
      final cmp = ad.compareTo(bd);
      if (cmp != 0) return cmp;
      final at = a.startTime?.hour ?? 999;
      final bt = b.startTime?.hour ?? 999;
      return at.compareTo(bt);
    });
  }

  // Group tasks by date (date only)
  Map<DateTime, List<Task>> _groupedForAllTasks() {
    final map = <DateTime, List<Task>>{};
    for (var t in _tasks) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      map.putIfAbsent(key, () => []).add(t);
    }

    // Sort keys ascending (earlier first)
    final keys = map.keys.toList()..sort((a, b) => a.compareTo(b));

    final LinkedHashMap<DateTime, List<Task>> ordered = LinkedHashMap();
    for (var k in keys) {
      final items = map[k]!;
      items.sort((a, b) {
        final at = a.startTime?.hour ?? 999;
        final bt = b.startTime?.hour ?? 999;
        return at.compareTo(bt);
      });
      ordered[k] = items;
    }
    return ordered;
  }

  // Return only tasks for the selected day
  List<Task> _tasksForSelectedDay() {
    return _tasks.where((t) {
      return t.date.year == _selectedDay.year &&
          t.date.month == _selectedDay.month &&
          t.date.day == _selectedDay.day;
    }).toList();
  }

  Future<void> _openCreate() async {
    final Task? created = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
    );
    if (created != null) {
      setState(() {
        _tasks.add(created);
        _normalizeTasks();
      });
    }
  }

  void _deleteTask(Task t) {
    setState(() {
      _tasks.removeWhere((x) => x.id == t.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedForAllTasks(); // For UI visibility
    final tasksForDay = _tasksForSelectedDay();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0,
        title: Row(
          children: [
            // Right Search Icon
            _buildNeumorphicButton(
              icon: Icons.search,
              onPressed: () {
                // Add search functionality here
              },
              size: 24,
              iconColor: Colors.blue,
            ),
            const SizedBox(width: 10),
            // Current Month and Year Title
            Text(
              DateFormat('MMMM yyyy').format(DateTime.now()),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
          setState(() {
            _normalizeTasks();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Week Strip (Mon..Thu)
                WeekStrip(
                  selected: _selectedDay,
                  onDaySelected: (d) => setState(() => _selectedDay = d),
                ),
                const SizedBox(height: 16),

                // Subheading: Showing selected day nicely
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('EEEE, dd MMM').format(_selectedDay),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('${tasksForDay.length} tasks', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 12),

                // Tasks filtered by selected day
                if (tasksForDay.isEmpty)
                  Container(
                    height: 260,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        const Text('No tasks for this day', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  )
                else
                  Column(
                    children: tasksForDay.map((t) => TaskCard(task: t, onDelete: () => _deleteTask(t))).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0, // Home Page Index
        onTap: (index) {
          // Handle the tap for navigation
          // For now, we just log it to console
          if (index == 0) {
            print('Home tapped');
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
            );
          } else if (index == 2) {
            // Go to Profile Page
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildNeumorphicButton(
              icon: Icons.home,
              onPressed: () {},
              size: 28,
              iconColor: Colors.blue,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildNeumorphicButton(
              icon: Icons.add,
              onPressed: _openCreate,
              size: 28,
              iconColor: Colors.green,
            ),
            label: 'Add Task',
          ),
          BottomNavigationBarItem(
            icon: _buildNeumorphicButton(
              icon: Icons.person,
              onPressed: () {},
              size: 28,
              iconColor: Colors.orange,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Neumorphic button styling
  Widget _buildNeumorphicButton({
    required IconData icon,
    required void Function() onPressed,
    double size = 28,
    Color iconColor = Colors.deepPurpleAccent,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
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
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
        iconSize: size,
      ),
    );
  }
}