import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thiran_assessment/models/taskModel.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();

  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  String _category = 'Work';

  final List<String> categories = ['Work', 'Personal', 'Health', 'Study', 'Other'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStart) _start = picked;
        else _end = picked;
      });
    }
  }

  void _create() {
    if (!_form.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a date')));
      return;
    }

    if (_start != null && _end != null) {
      final s = _start!.hour * 60 + _start!.minute;
      final e = _end!.hour * 60 + _end!.minute;
      if (e <= s) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time must be after start time')));
        return;
      }
    }

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      category: _category,
      date: _date!,
      startTime: _start,
      endTime: _end,
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );

    Navigator.of(context).pop(task);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _date == null ? 'Pick date' : DateFormat.yMMMd().format(_date!);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dateLabel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text(_start == null ? 'Start time' : _start!.format(context)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(false),
                      icon: const Icon(Icons.access_time),
                      label: Text(_end == null ? 'End time' : _end!.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: categories.map((c) {
                  final selected = _category == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) => setState(() => _category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _create,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Create Task', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
