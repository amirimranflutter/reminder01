import 'package:flutter/material.dart';
import 'package:reminder/reminder01/database/database_helper.dart';

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
        if(!snapshot.hasData){
        return Scaffold(
          body: Center(child: CircularProgressIndicator(
            color: Colors.teal,
          ),),
        );}
        final reminder=snapshot.data!;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text('Reminder Details'),
            centerTitle: true,
          ),
          
          body: Padding(padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            ],
          ),),
        );
      },
    );
  }
}
