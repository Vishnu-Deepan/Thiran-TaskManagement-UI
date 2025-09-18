import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiran_assessment/models/taskModel.dart';

class TaskStorage {
  static const _key = 'tasks_v1';

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null) return [];
    final decoded = jsonDecode(s) as List<dynamic>;
    return decoded.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }
}
