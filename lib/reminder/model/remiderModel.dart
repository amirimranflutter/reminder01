// models/reminder.dart
class Reminder {
  int? id;
  String title;
  String description;
  DateTime dateTime;
  bool isCompleted;
  String priority;

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.priority = 'Medium',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      isCompleted: map['isCompleted'] == 1,
      priority: map['priority'],
    );
  }
}
