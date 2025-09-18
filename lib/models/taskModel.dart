import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? description;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.startTime,
    this.endTime,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'date': date.toIso8601String(),
    'startHour': startTime?.hour,
    'startMinute': startTime?.minute,
    'endHour': endTime?.hour,
    'endMinute': endTime?.minute,
    'description': description,
  };

  factory Task.fromJson(Map<String, dynamic> j) {
    TimeOfDay? _toTime(int? h, int? m) => (h != null && m != null) ? TimeOfDay(hour: h, minute: m) : null;

    return Task(
      id: j['id'],
      title: j['title'],
      category: j['category'],
      date: DateTime.parse(j['date']),
      startTime: _toTime(j['startHour'], j['startMinute']),
      endTime: _toTime(j['endHour'], j['endMinute']),
      description: j['description'],
    );
  }
}