import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/InstantMessage.dart';
import 'Contact.dart';
import 'Message.dart';
import 'main.dart';

/// Represents the WhatsApp chat screen
class Chat extends StatefulWidget {
  final Contact contact;

  const Chat({Key key, this.contact}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // for user input
  final TextEditingController messageController = TextEditingController();
  // connect to server when open a Chat Screen
  final IOWebSocketChannel chatChannel = IOWebSocketChannel
      .connect('ws://192.168.1.10:8080');
  // text messages view
  final chatListView = [];
  // chat must scroll down at every received message
  ScrollController controller = ScrollController();
  // read from user
  var input;
  // initialize the chat
  var first = true;
  // Stop looping if there is also the same message on the stream
  var lastMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: PRIMARY_COLOR,
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                  child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      // Update in chatTab first chat
                      onPressed: () => Navigator.pop(context, widget.contact)
                  )
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/default_profile_pic.png'), //widget.contact.profileImage,
                  backgroundColor: PRIMARY_COLOR,),
              ),
              Text(widget.contact.username),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () => {},
                icon: Icon(Icons.videocam_rounded)),
            IconButton(onPressed: () => {},
                icon: Icon(Icons.call)),
            IconButton(onPressed: () => {},
                icon: Icon(Icons.more_vert)),
          ],
        ),
        body: StreamBuilder(
            stream: chatChannel.stream,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              // load list for the first time
              if (first) {
                setup();
              }
              // add message of other client
              if (snapshot.hasData && lastMessage != snapshot.data) {
                lastMessage = snapshot.data;
                var json = jsonDecode('${snapshot.data}'.split("chatWith:")[1]);
                Message m = Message(json['message'], true);
                chatListView.add(
                    buildMessageLayout(m));
              }
              return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Opacity(
                          opacity: 0.1,
                          child: Image(
                              image: AssetImage('images/chat_bg.png'))),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              controller: controller,
                              itemCount: chatListView.length,
                              itemBuilder: (BuildContext context, int index) {
                                // after 300 ms scroll down the list
                                Timer(Duration(milliseconds: 300), () {
                                  controller.jumpTo(
                                      controller.position.maxScrollExtent);
                                });
                                return chatListView[index];
                              }),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextField(
                                  controller: messageController,
                                  style: TextStyle(color: TEXT_COLOR),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: PRIMARY_COLOR,
                                    prefixIcon: Icon(
                                      Icons.emoji_emotions,
                                      color: Colors.grey,),
                                    contentPadding: EdgeInsets.only(left: 8),
                                    hintText: 'Scrivi un messaggio',
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.attachment),
                                          color: TEXT_COLOR, onPressed: () {},),
                                        IconButton(
                                          icon: Icon(
                                              Icons.photo_camera_rounded),
                                          color: TEXT_COLOR, onPressed: () {},),
                                      ],
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.circle, color: SECONDARY_COLOR,
                                    size: 56,
                                  ),
                                  IconButton(onPressed: () {
                                    // save user input
                                    input = messageController.text;
                                    Message m = Message(input, false);
                                    widget.contact.messages.add(m);
                                    chatListView.add(buildMessageLayout(
                                        m));
                                    messageController.text = '';
                                    // encode message as Json object
                                    var jsonMessage = jsonEncode(InstantMessage(
                                        widget.contact.phone, input).toJson());
                                    String message = "sendTo: " + jsonMessage;
                                    setState(() {
                                      // send to server
                                      chatChannel.sink.add(message);
                                    });
                                    // after 300 ms scroll down the list
                                    Timer(Duration(milliseconds: 300), () {
                                      controller.jumpTo(
                                          controller.position.maxScrollExtent);
                                    });
                                  },
                                      icon: Icon(
                                          Icons.send, color: Colors.white)
                                  )
                                ]
                            )
                          ],
                        ),
                      ],
                    ),
                  ]
              );
            }
        )
    );
  }

  /// On opening Chat screen all messages are loaded
  buildInitialList() {
    for (var m in widget.contact.messages) {
      if (m.text.isNotEmpty) {
        chatListView.add(
            buildMessageLayout(m));
      }
    }
  }

  /// Build message view, am i the sender or not?
  buildMessageLayout(Message message) {
    return Align(
        alignment: message.fromServer
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              constraints: BoxConstraints(maxWidth: 350),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: message.fromServer
                    ? PRIMARY_COLOR
                    : CHAT_COLOR,
              ),
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible( // WHAT'S A MAGIC THIS FRAMEWORK!
                    child: Text(
                        message.text,
                        style: TextStyle(
                            color: TEXT_COLOR,
                            fontSize: 16)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 8.0, right: 4),
                    child: Text(message.timestamp,
                        style: TextStyle(
                            height: 2,
                            color: Colors.grey,
                            fontSize: 10)
                    ),
                  ),
                  if (!message.fromServer)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Icon(Icons.done_all, color: Colors.blue, size: 16),
                    )
                ],
              )
          ),
        )
    );
  }

  /// Tell to the server that I want to start a chat
  void setup() {
    first = !first;
    // Read from SharedPreferences
    SharedPreferences.getInstance().then((value) {
      String message = 'initializeSocketChat ';
      message += value.getString(PHONE_NUMBER) + " ";
      message += value.getString(USERNAME) + " ";
      //message += value.getString(PHOTO) + " ";
      message += "photo";
      chatChannel.sink.add(message);
      setState(() {
        buildInitialList();
      });
    });
  }
}