import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thiran_assessment/models/taskModel.dart';
import 'package:thiran_assessment/screens/CreateTaskScreen/createTaskScreen.dart';
import 'package:thiran_assessment/screens/TaskListScreen/widgets/taskCard.dart';
import 'package:thiran_assessment/screens/TaskListScreen/widgets/weekStrip.dart';
import 'package:thiran_assessment/utils/date_utils.dart';
import 'package:thiran_assessment/utils/taskStorage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _loading = true;
  DateTime _selectedWeekDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loaded = await TaskStorage.loadTasks();
    // sort loaded: newest first by date/time
    loaded.sort(_taskComparator);
    setState(() {
      _tasks.addAll(loaded);
      _loading = false;
    });
  }

  int _taskComparator(Task a, Task b) {
    // first by date desc
    final ad = DateTime(a.date.year, a.date.month, a.date.day);
    final bd = DateTime(b.date.year, b.date.month, b.date.day);
    final dateCmp = bd.compareTo(ad); // descending
    if (dateCmp != 0) return dateCmp;

    // then by start time ascending (nulls last)
    int _timeVal(TimeOfDay? t) => t == null ? 9999 : t.hour * 60 + t.minute;
    return _timeVal(a.startTime).compareTo(_timeVal(b.startTime));
  }

  /// Group into ordered map DateTime -> List<Task> (date-only keys, latest date first)
  LinkedHashMap<DateTime, List<Task>> groupedTasks() {
    final map = <DateTime, List<Task>>{};
    for (final t in _tasks) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      map.putIfAbsent(key, () => []).add(t);
    }
    final entries = map.entries.toList();
    entries.sort((a, b) => b.key.compareTo(a.key)); // latest first
    final ordered = LinkedHashMap<DateTime, List<Task>>();
    for (final e in entries) {
      final items = e.value..sort(_taskComparator);
      ordered[e.key] = items;
    }
    return ordered;
  }

  String _daysAgo(DateTime d) => daysAgoCompact(d);

  Future<void> _openCreate() async {
    final Task? created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
    );
    if (created != null) _insertTask(created);
  }

  void _insertTask(Task task) {
    setState(() {
      _tasks.insert(0, task);
      _tasks.sort(_taskComparator);
    });
    // rebuild list: to animate, find index
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    _listKey.currentState?.insertItem(idx);
    TaskStorage.saveTasks(_tasks);
  }

  void _deleteAtIndex(int index) {
    final removed = _tasks[index];
    setState(() => _tasks.removeAt(index));
    _listKey.currentState?.removeItem(
      index,
          (context, anim) => SizeTransition(
        sizeFactor: anim,
        child: TaskCard(
          task: removed,
          daysAgo: _daysAgo(removed.date),
          onDelete: () {},
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );
    TaskStorage.saveTasks(_tasks);
  }

  // find index in flat list for AnimatedList builder
  List<Task> _flatListFromGrouped(LinkedHashMap<DateTime, List<Task>> grouped) {
    final flat = <Task>[];
    for (final entry in grouped.entries) {
      flat.addAll(entry.value);
    }
    return flat;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupedTasks();
    final flat = _flatListFromGrouped(grouped);
    final weekDays = _weekDaysMonToThu(_selectedWeekDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await TaskStorage.loadTasks().then((loaded) {
            setState(() {
              _tasks
                ..clear()
                ..addAll(loaded..sort(_taskComparator));
            });
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              WeekStrip(
                selected: _selectedWeekDay,
                onDaySelected: (d) => setState(() => _selectedWeekDay = d),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: grouped.isEmpty
                    ? const Center(child: Text('No tasks yet. Tap + to add.'))
                    : AnimatedList(
                  key: _listKey,
                  initialItemCount: flat.length,
                  itemBuilder: (context, index, animation) {
                    final task = flat[index];
                    return SizeTransition(
                      sizeFactor: animation,
                      child: _buildItemWithDateHeaders(grouped, task, flat, index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds item and inserts a date header above the first item of each date group.
  Widget _buildItemWithDateHeaders(LinkedHashMap<DateTime, List<Task>> grouped, Task task, List<Task> flat, int index) {
    // find date header presence: if this is the first occurrence of this date in flat list -> show header
    final dateKey = DateTime(task.date.year, task.date.month, task.date.day);
    final firstIndexOfDate = flat.indexWhere((t) => DateTime(t.date.year, t.date.month, t.date.day) == dateKey);
    final showHeader = index == firstIndexOfDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
            child: Text(prettyDateHeader(dateKey), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        TaskCard(
          task: task,
          daysAgo: _daysAgo(task.date),
          onDelete: () {
            // map flat index -> actual index in _tasks to remove
            final actualIndex = _tasks.indexWhere((t) => t.id == task.id);
            if (actualIndex != -1) _deleteAtIndex(actualIndex);
          },
        ),
      ],
    );
  }

  List<DateTime> _weekDaysMonToThu(DateTime ref) {
    final weekday = ref.weekday;
    final monday = ref.subtract(Duration(days: weekday - 1));
    return List.generate(4, (i) => monday.add(Duration(days: i)));
  }
}
