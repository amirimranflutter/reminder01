
// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/remiderModel.dart';
import '../model/service/databaseService.dart';
import '../model/service/notificcationService.dart';
import 'addReminderScreen.dart';
import 'editReminderScreen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Reminder> reminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => isLoading = true);
    final data = await DatabaseService.getAllReminders();
    setState(() {
      reminders = data;
      isLoading = false;
    });
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    await DatabaseService.deleteReminder(reminder.id!);
    await NotificationService.cancelNotification(reminder.id!);
    _loadReminders();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder deleted')),
    );
  }

  Future<void> _toggleComplete(Reminder reminder) async {
    reminder.isCompleted = !reminder.isCompleted;
    await DatabaseService.updateReminder(reminder);
    if (reminder.isCompleted) {
      await NotificationService.cancelNotification(reminder.id!);
    } else {
      await NotificationService.scheduleNotification(reminder);
    }
    _loadReminders();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Reminders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : reminders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No reminders yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add your first reminder',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadReminders,
        child: ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            final isOverdue = reminder.dateTime.isBefore(DateTime.now()) && !reminder.isCompleted;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getPriorityColor(reminder.priority),
                  child: Icon(
                    reminder.isCompleted ? Icons.check : Icons.notifications,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  reminder.title,
                  style: TextStyle(
                    decoration: reminder.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.description),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy - HH:mm').format(reminder.dateTime),
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.grey,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    if (isOverdue)
                      Text(
                        'OVERDUE',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'complete',
                      child: Row(
                        children: [
                          Icon(reminder.isCompleted ? Icons.undo : Icons.check),
                          SizedBox(width: 8),
                          Text(reminder.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'complete':
                        await _toggleComplete(reminder);
                        break;
                      case 'edit':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditReminderScreen(reminder: reminder),
                          ),
                        ).then((_) => _loadReminders());
                        break;
                      case 'delete':
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Reminder'),
                            content: Text('Are you sure you want to delete this reminder?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteReminder(reminder);
                                },
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReminderScreen()),
          ).then((_) => _loadReminders());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
