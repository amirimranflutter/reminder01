import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder/reminder01/database/database_helper.dart';
import 'package:reminder/reminder01/screen/editreminderScreen.dart';

class ReminderDetailScreen extends StatefulWidget {
  const ReminderDetailScreen({super.key, required this.reminderId});

  final int reminderId;

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DbHelper.getReminderById(widget.reminderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if(snapshot.connectionState==ConnectionState.waiting){
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }}
        if(!snapshot.hasData||snapshot.data==null){    print('No data found for reminder ID: ${widget.reminderId}');
        return Scaffold(
          body: Center(child: Text('Reminder not found')),
        );
        }
        final reminder = snapshot.data!;
        print('reminder======>$reminder');
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text('Reminder Details'),
            centerTitle: true,
          ),

          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailCard(
                  label: 'Title',
                  icon: Icons.title,
                  content: reminder['title'],
                ),
                SizedBox(height: 20),
                _buildDetailCard(
                  label: 'Description',
                  icon: Icons.description,
                  content: reminder['description'],
                ),
                SizedBox(height: 20),
                _buildDetailCard(
                  label: 'Category',
                  icon: Icons.category,
                  content: reminder['category'],
                ),
                SizedBox(height: 20),
                _buildDetailCard(
                  label: 'Reminder Time',
                  icon: Icons.access_time,
                  content: DateFormat(
                    'yyyy-MM-dd hh:mm',
                  ).format(DateTime.parse(reminder['reminderTime'])),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              onPressed: (){Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>AddEditReminderScreen(reminderId: reminder['id'],)),
            );}
          ),
        );
      },
    );
  }

  Widget _buildDetailCard({
    required String label,
    required IconData icon,
    required String content,
  }) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
