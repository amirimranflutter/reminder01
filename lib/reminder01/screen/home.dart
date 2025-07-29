import 'package:flutter/material.dart';
import 'package:reminder/reminder01/database/database_helper.dart';
import 'package:reminder/reminder01/notification/notification_helper.dart';
import 'package:reminder/reminder01/screen/editreminderScreen.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  List<Map<String, dynamic>> _reminder = [];

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final reminders = await DbHelper.getReminder();
    setState(() {
      _reminder = reminders;
    });
  }

  Future<void> _toggleReminder(int id, bool isActive) async {
    await DbHelper.toggleReminder(id, isActive);
    if (isActive) {
      final reminder = _reminder.firstWhere((rem) => rem['id'] == id);
      NotificationHelper.scheduleNotification(
        id,
        reminder['title'],
        reminder['category'],
        DateTime.parse(reminder['reminderTime']),
      );
    } else {
      NotificationHelper.cancelNotification(id);
    }
    _loadReminder();
  }

  Future<void> _deleteReminder(int id) async {
    await DbHelper.deleteReminder(id);
    NotificationHelper.cancelNotification(id);
    _loadReminder();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Reminder App', style: TextStyle(color: Colors.teal)),
          iconTheme: IconThemeData(color: Colors.teal),
        ),
        body: _reminder.isEmpty
            ? Center(
          child: Text(
            "No Reminder Found",
            style: TextStyle(fontSize: 18, color: Colors.teal),
          ),
        )
            : ListView.builder(
          itemCount: _reminder.length,
          itemBuilder: (context, index) {
            final reminder = _reminder[index];
            return Dismissible(
              key: Key(reminder['id'].toString()),
              child: Card(
                color: Colors.teal,
                elevation: 6,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                ),
                child: ListTile(

                ),),
              direction: DismissDirection.endToStart,
              background: Container(color: Colors.redAccent,

                padding: EdgeInsets.only(right: 20),
                alignment: Alignment.centerRight,
                child: Icon(Icons.delete, color: Colors.white, size: 30,),
              ),
              confirmDismiss: (direction) async {
                // return await _showDeleteConfirmationDialog(context);
              },
              onDismissed: (direction) {
                _deleteReminder(reminder['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Reminder is deleted")));
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEditReminderScreen()));
        },
            child: Icon(Icons.add),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,

        ),
      ),
    );
  }
Future<bool?> _showDeleteConfirmationDialog(BuildContext context){
    return showDialog(context: context, builder: (BuildContext content){
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete Reminder'),
        content: Text('Are you sure you want to delete this reminder?'),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
      }, child: Text("cancel"),

        ),
        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        }, child: Text("delete",style: TextStyle(color: Colors.redAccent ),),

        )],
      );
    });
}

}