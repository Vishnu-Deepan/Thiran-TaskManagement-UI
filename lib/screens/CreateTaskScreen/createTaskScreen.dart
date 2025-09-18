import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thiran_assessment/models/taskModel.dart';
import 'package:thiran_assessment/screens/TaskListScreen/taskListScreen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _form = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _start;
  TimeOfDay? _end;
  String _category = 'Work';

  final List<String> _categories = ['Work', 'Personal', 'Health', 'Study', 'Other'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(bool start) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (start) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time selection cancelled. Please select a time.')),
      );
    }
  }

  void _submit() {

    // Check if the title is entered
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    // Validate the category
    if (_category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    // Validate the selected date
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    // Create the task object
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      category: _category, // No need for '!' here, since _category is not nullable
      date: _selectedDate, // No need for '!' here, since _selectedDate is initialized
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );

    // Return the task to the previous screen
    Navigator.of(context).pop(task);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMd().format(_selectedDate);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://img.freepik.com/premium-vector/blue-abstract-background-blue-simple-background_680692-48.jpg'), // Replace with your image URL
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken), // Optional: To dim the image
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const HomePage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                ),
                Text(
                  "Create New Task",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
                ),
                SizedBox(width: 80),
              ],
            ),
            // Top Section: Title and Description
            _buildTopSection(),
            SizedBox(height: 10),
            // Bottom Section: Modal sheet-like container with rounded top corners
            _buildBottomSection(dateLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitleWhite('Task Title'),
          _buildTextField('Enter task title', _titleCtrl),
          const SizedBox(height: 16),
          _buildSectionTitleWhite('Description'),
          _buildTextField('Enter description', _descCtrl, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildSectionTitleWhite(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomSection(String dateLabel) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 3, blurRadius: 8, offset: const Offset(0, -4)),
          ],
        ),
        padding: const EdgeInsets.all(26),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildSectionTitle('Due Date'),
              _buildDateTimePicker(dateLabel, _pickDate, Icons.calendar_today),
              const SizedBox(height: 16),
              _buildSectionTitle('Time Range'),
              _buildTimePickerRow(),
              const SizedBox(height: 16),
              _buildSectionTitle('Category'),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? '$label required' : null,
      ),
    );
  }

  Widget _buildDateTimePicker(String label, void Function() onPressed, IconData icon) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.indigo),
        label: Text(label, style: TextStyle(color: Colors.indigo)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.indigo),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildTimePickerRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDateTimePicker(
            _start == null ? 'Start Time' : _start!.format(context),
                () => _pickTime(true),
            Icons.access_time,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDateTimePicker(
            _end == null ? 'End Time' : _end!.format(context),
                () => _pickTime(false),
            Icons.access_time,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      children: _categories.map((c) {
        final selected = _category == c;
        return ChoiceChip(
          showCheckmark: false,
          label: Text(c),
          selected: selected,
          onSelected: (_) => setState(() => _category = c),
          selectedColor: Colors.indigo,
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
          shadowColor: Colors.grey.withOpacity(0.5),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text('Create Task', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
