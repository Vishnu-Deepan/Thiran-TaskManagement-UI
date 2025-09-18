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

  // Static method to convert TimeOfDay to an int (minutes since midnight)
  static int? timeToMinutes(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }

  // Static method to convert minutes since midnight to TimeOfDay
  static TimeOfDay? minutesToTime(int? minutes) {
    if (minutes == null) return null;
    int hour = minutes ~/ 60;
    int minute = minutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Converts a Task object into a Map (for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date.toIso8601String(), // Convert DateTime to string
      'startTime': timeToMinutes(startTime), // Store time as minutes since midnight
      'endTime': timeToMinutes(endTime), // Store time as minutes since midnight
      'description': description,
    };
  }

  // Creates a Task object from a Map (for JSON deserialization)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String), // Convert string back to DateTime
      startTime: json['startTime'] != null ? minutesToTime(json['startTime'] as int) : null,
      endTime: json['endTime'] != null ? minutesToTime(json['endTime'] as int) : null,
      description: json['description'] as String?,
    );
  }
}
