import 'package:chatphi_voip/models/call_history.dart';
import 'package:flutter/material.dart';

class CallHistoryScreen extends StatelessWidget {
  final List<CallHistory> callHistoryList;

  CallHistoryScreen({required this.callHistoryList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Call History')),
      body: ListView.builder(
        itemCount: callHistoryList.length,
        itemBuilder: (context, index) {
          final call = callHistoryList[index];
          
          return ListTile(
            title: Text('Call ID: ${call.callId}'),
            subtitle: Text(
              'From: ${call.callerName}\nStart: ${call.startTime}\nEnd: ${call.endTime}\nDuration: ${call.duration.inMinutes} min',
            ),
            leading: Icon(Icons.call),
          );
        },
      ),
    );
  }
}
