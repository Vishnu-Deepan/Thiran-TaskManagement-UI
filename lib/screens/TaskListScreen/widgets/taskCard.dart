import 'package:flutter/material.dart';
import 'package:thiran_assessment/models/taskModel.dart';
import 'package:thiran_assessment/utils/date_utils.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const TaskCard({super.key, required this.task, required this.onDelete});

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
    if (task.startTime == null && task.endTime == null) return '';
    if (task.startTime != null && task.endTime != null) {
      return '${task.startTime!.format(context)} to ${task.endTime!.format(context)}';
    }
    if (task.startTime != null) return task.startTime!.format(context);
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(task.category);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.2),
            offset: const Offset(-5, -5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left icon (Neumorphic style)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    offset: const Offset(-5, -5),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    offset: const Offset(5, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.calendar_today,
                color: Colors.black,
                size: 30,
                semanticLabel: 'task icon',
              ),
            ),
            const SizedBox(width: 20),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Time + Relative Date + Category - stacked vertically for spacing
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_timeRange(context).isNotEmpty)
                        Text(
                          _timeRange(context),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      if (_timeRange(context).isNotEmpty) const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            compactRelative(task.date),
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Chip(
                            label: Text(
                              task.category,
                              style: TextStyle(color: color, fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: color.withOpacity(0.1),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description - allow more space, wrap nicely
                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                      task.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),

            // Delete button (Neumorphic)
            _buildNeumorphicButton(
              icon: Icons.more_vert,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text('Delete'),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            onDelete();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.close),
                          title: const Text('Close'),
                          onTap: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Neumorphic button
  Widget _buildNeumorphicButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(-5, -5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            offset: const Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 28,
          color: Colors.black45,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
