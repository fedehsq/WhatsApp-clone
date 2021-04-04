
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'PhoneNumberSetup.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}



class _ChatListState extends State<ChatList> {
  String getTime() {
    var now = new DateTime.now();
    var formatter = new DateFormat('hh:mm');
    String formattedDate = formatter.format(now);
    return formattedDate; // 2016-01-25
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: 8),
        children: [
          for (int i = 0; i < 20; i++)
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('images/account.png'),),
              title:
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Chat $i', style: TextStyle(color: TEXT_COLOR),),
                        Text(getTime(), style: TextStyle(color: Colors.grey, fontSize: 10),)
                      ],
                    ),
                  ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.done_all, color: i % 2 == 0 ? Colors.blue : Colors.grey, size: 16,),
                        Text(' Last message from $i', style: TextStyle(color: Colors.grey),),
                      ],
                    ),
                  ),
                  Divider(height: 20,  color: Colors.grey,)
                ],
              ),
            )
        ],

      )
    );
  }
}
