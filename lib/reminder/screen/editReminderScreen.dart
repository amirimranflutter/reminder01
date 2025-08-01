
// screens/edit_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/remiderModel.dart';
import '../model/service/databaseService.dart';
import '../model/service/notificcationService.dart';


class EditReminderScreen extends StatefulWidget {
  final Reminder reminder;

  EditReminderScreen({required this.reminder});

  @override
  _EditReminderScreenState createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDateTime;
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder.title);
    _descriptionController = TextEditingController(text: widget.reminder.description);
    _selectedDateTime = widget.reminder.dateTime;
    _selectedPriority = widget.reminder.priority;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Reminder'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a description";
                    }
                    return null;
                  }
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a description";
                    }
                    return null;
                  }
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Date & Time'),
                subtitle: Text(DateFormat('MMM dd, yyyy - HH:mm').format(_selectedDateTime)),
                leading: Icon(Icons.calendar_today),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => _selectDateTime(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: ['High', 'Medium', 'Low'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Update Reminder', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _updateReminder() async {
    if (_formKey.currentState!.validate()) {
      final updatedReminder = Reminder(
        id: widget.reminder.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dateTime: _selectedDateTime,
        priority: _selectedPriority,
        isCompleted: widget.reminder.isCompleted,
      );

      await DatabaseService.updateReminder(updatedReminder);

      // Cancel old notification and schedule new one
      await NotificationService.cancelNotification(widget.reminder.id!);
      if (!updatedReminder.isCompleted) {
        await NotificationService.scheduleNotification(updatedReminder);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder updated successfully!')),
      );

      Navigator.pop(context);
    }
  }
}