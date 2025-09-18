import 'package:flutter/material.dart';
import 'package:thiran_assessment/models/taskModel.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String daysAgo;
  final VoidCallback onDelete;

  const TaskCard({super.key, required this.task, required this.daysAgo, required this.onDelete});

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'work':
        return Colors.indigo;
      case 'personal':
        return Colors.teal;
      case 'health':
        return Colors.orange;
      case 'study':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _timeRange(BuildContext context) {
    final start = task.startTime;
    final end = task.endTime;
    if (start == null && end == null) return '';
    if (start != null && end != null) return '${start.format(context)} - ${end.format(context)}';
    if (start != null) return start.format(context);
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(task.category);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(Icons.task_alt, color: color, semanticLabel: 'Task Icon'),
        ),
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.startTime != null || task.endTime != null) ...[
              Text(_timeRange(context), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
            ],
            Row(
              children: [
                Text(daysAgo, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Chip(
                  label: Text(task.category),
                  backgroundColor: color.withOpacity(0.12),
                  labelStyle: TextStyle(color: color, fontSize: 12),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(task.description!, style: const TextStyle(fontSize: 13)),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Delete task',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
