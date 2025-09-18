import 'package:flutter/material.dart';
import 'package:thiran_assessment/screens/TaskListScreen/taskListScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
