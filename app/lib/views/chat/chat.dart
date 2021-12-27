// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/api.dart';
import 'package:whatsapp_clone/managers/preference_manager.dart';
import 'package:whatsapp_clone/models/instant_message.dart';
import '../../models/contact.dart';
import '../../models/message.dart';
import '../../main.dart';

/// QUANDO TORNO INDIETRO CONTROLLO SE L'ORA LA QUALE SONO USCITO è > DELLA LAST CONTACT, SE è COSì, SWAPPO!

/// Represents the WhatsApp chat screen
class Chat extends StatefulWidget {
  final Contact contact;

  const Chat({Key? key, required this.contact}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with WidgetsBindingObserver {
  // for user input
  final TextEditingController messageController = TextEditingController();

  // connect to server when open a Chat Screen
  IOWebSocketChannel chatChannel =
      IOWebSocketChannel.connect('ws://192.168.1.4:8080');

  // text messages view
  final chatListView = [];

  // chat must scroll down at every received message
  ScrollController controller = ScrollController();

  // read from user
  String input = '';

  // initialize the chat
  bool first = true;

  // Index of notification messages, so i know how to remove it in O(1)
  // when tap ok keyboard
  int notifyPosition = -1;

  // Stop looping if there is also the same message on the stream
  var lastMessage = '';

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance!.addObserver(this);
    // WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // Re-open from bg
      case AppLifecycleState.resumed:
        // Next time in app opening, login again
        first = true;
        chatChannel = IOWebSocketChannel.connect(server);
        break;
      // Just a second before 'paused'
      case AppLifecycleState.inactive:
        break;
      // App still opens in bg
      case AppLifecycleState.paused:
        // Send offline status to server
        chatChannel.sink.add(jsonEncode({
          'operation': offline,
          'body': {'phone': SharedPreferencesManager.getPhoneNumber()}
        }));
        chatChannel.sink.close();
        break;
      // On hard close app (remove from bg)
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 8, 24, 33),
        body: StreamBuilder(
            stream: chatChannel.stream,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              // load list for the first time
              if (first) {
                setup();
              }
              // Add message of other client (check if the stream in new)
              if (snapshot.hasData && lastMessage != snapshot.data) {
                lastMessage = snapshot.data;

                var message = '${snapshot.data}'.split(": ")[0];
                var json = jsonDecode('${snapshot.data}'.split(": ")[1]);

                // Switch operations
                switch (message) {
                  // Single message, when I am online
                  case "MESSAGE_FROM":
                    // I MUST ALSO CHECK THAT THE SENDER IS THE CONTACT WITH WHOM I AM IN THE CHAT!
                    // BECAUSE ANYONE SEND ME A MESSAGE, I RECEIVE THAT!
                    if (widget.contact.phone == json['phone']) {
                      Message m = Message(json['message'], true);
                      chatListView.add(buildMessageLayout(m));
                    }
                    break;
                  // One or more message, while I am offline
                  case "MESSAGES_FROM":
                    // How many messages have I received while I was offline?
                    int toRead = 0;
                    for (var message in json) {
                      toRead++;
                      var json = jsonDecode(message);
                      if (widget.contact.phone == json['phone']) {
                        Message m = Message(json['message'], true);
                        chatListView.add(buildMessageLayout(m));
                      }
                    }
                    if (toRead > 0) {
                      chatListView.insert(
                          notifyPosition = chatListView.length - toRead,
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Opacity(
                                opacity: 0.5,
                                child: Center(
                                    child: Text(
                                  '$toRead nuovi messaggi',
                                  style: const TextStyle(color: Colors.white),
                                ))),
                          ));
                    }

                    break;
                  // A client is gone offline
                  case 'OFFLINE':
                    // Check if he is my peer
                    if (widget.contact.phone == json['phone']) {
                      widget.contact.isOnline = false;
                    }
                    break;

                  // A client is coming online
                  case 'ONLINE':
                    // Check if he is my peer
                    if (widget.contact.phone == json['phone']) {
                      widget.contact.isOnline = true;
                    }
                    break;
                }
                // after 300 ms scroll down the list
                Timer(const Duration(milliseconds: 500), () {
                  try {
                    controller.jumpTo(controller.position.maxScrollExtent);
                  } catch (e) {}
                });
              }
              return Stack(children: [
                const SingleChildScrollView(
                  child: Opacity(
                      opacity: 0.1,
                      child: Padding(
                        padding: EdgeInsets.only(top: 64.0),
                        child: Image(image: AssetImage('images/chat_bg.png')),
                      )),
                ),
                Column(
                  children: [
                    AppBar(
                      backgroundColor: primaryColor,
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
                                  icon: const Icon(Icons.arrow_back),
                                  // Remove the flag of notification from this chat
                                  onPressed: () {
                                    widget.contact.toRead = 0;
                                    Navigator.pop(context, widget.contact);
                                  })),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundImage:
                                  widget.contact.profileImage.image,
                              //widget.contact.profileImage,
                              backgroundColor: primaryColor,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.contact.username,
                                  style: const TextStyle(fontSize: 17)),
                              if (widget.contact.isOnline)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text('Online',
                                      style: TextStyle(fontSize: 10)),
                                )
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                            onPressed: () => {},
                            icon: const Icon(Icons.videocam_rounded)),
                        IconButton(
                            onPressed: () => {}, icon: const Icon(Icons.call)),
                        IconButton(
                            onPressed: () => {},
                            icon: const Icon(Icons.more_vert)),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                          controller: controller,
                          itemCount: chatListView.length,
                          itemBuilder: (BuildContext context, int index) {
                            return chatListView[index];
                          }),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TextField(
                              onTap: () {
                                Timer(const Duration(milliseconds: 500), () {
                                  try {
                                    controller.jumpTo(
                                        controller.position.maxScrollExtent);
                                  } catch (e) {}
                                });
                                // Remove message that indicates notification
                                if (notifyPosition != -1) {
                                  setState(() {
                                    chatListView.removeAt(notifyPosition);
                                    notifyPosition = -1;
                                  });
                                }
                              },
                              onChanged: (String value) {
                                // Set photo icon if text is empty
                                setState(() {});
                              },
                              maxLines: null,
                              // go down when reached tot char
                              controller: messageController,
                              style: const TextStyle(color: textColor),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: primaryColor,
                                prefixIcon: const Icon(
                                  Icons.emoji_emotions,
                                  color: Colors.grey,
                                ),
                                contentPadding: const EdgeInsets.only(left: 8),
                                hintText: 'Scrivi un messaggio',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.attachment),
                                      color: textColor,
                                      onPressed: () {},
                                    ),
                                    if (messageController.text.isEmpty)
                                      IconButton(
                                        icon: const Icon(
                                            Icons.photo_camera_rounded),
                                        color: textColor,
                                        onPressed: () {},
                                      ),
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
                        Stack(alignment: Alignment.center, children: [
                          const Icon(
                            Icons.circle,
                            color: secondaryColor,
                            size: 56,
                          ),
                          IconButton(
                              onPressed: () {
                                // save user input
                                input = messageController.text;
                                if (input.isNotEmpty) {
                                  Message m = Message(input, false);
                                  widget.contact.messages.add(m);
                                  chatListView.add(buildMessageLayout(m));
                                  messageController.text = '';
                                  // encode message as Json object
                                  setState(() {
                                    // send to server
                                    chatChannel.sink.add(jsonEncode({
                                      'operation': send,
                                      'body': InstantMessage(
                                              widget.contact.phone, input)
                                          .toJson()
                                    }));
                                  });
                                  // after 300 ms scroll down the list
                                  Timer(const Duration(milliseconds: 500), () {
                                    try {
                                      controller.jumpTo(
                                          controller.position.maxScrollExtent);
                                    } catch (e) {}
                                  });
                                }
                              },
                              icon: const Icon(Icons.send, color: Colors.white))
                        ])
                      ],
                    ),
                  ],
                ),
              ]);
            }));
  }

  /// On opening Chat screen all messages are loaded
  buildInitialList() {
    for (var m in widget.contact.messages) {
      if (m.text.isNotEmpty) {
        chatListView.add(buildMessageLayout(m));
      }
    }
  }

  /// Build message view, am i the sender or not?
  buildMessageLayout(Message message) {
    return Align(
        alignment:
            message.fromServer ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              constraints: const BoxConstraints(maxWidth: 350),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: message.fromServer ? primaryColor : chatColor,
              ),
              padding: const EdgeInsets.all(8),
              child: Stack(alignment: Alignment.bottomRight, children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      // WHAT'S A MAGIC THIS FRAMEWORK!
                      child: Text(message.text,
                          style:
                              const TextStyle(color: textColor, fontSize: 16)),
                    ),
                    // Very tricky
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 2),
                      child: Text(
                          DateFormat('HH:mm').format(widget
                              .contact
                              .messages[widget.contact.messages.length - 1]
                              .timestamp),
                          style: const TextStyle(
                              color: Colors.transparent, fontSize: 10)),
                    ),
                    if (!message.fromServer)
                      const Icon(Icons.done_all,
                          color: Colors.transparent, size: 16)
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 2),
                      child: Text(
                          DateFormat('HH:mm').format(widget
                              .contact
                              .messages[widget.contact.messages.length - 1]
                              .timestamp),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 10)),
                    ),
                    if (!message.fromServer)
                      const Icon(Icons.done_all, color: Colors.blue, size: 16)
                  ],
                ),
              ])),
        ));
  }

  @override
  void dispose() {
    controller.dispose();
    chatChannel.sink.close();
    super.dispose();
  }

  /// Tell to the server that I want to start a chat
  void setup() {
    first = !first;
    chatChannel.sink.add(jsonEncode({
      'operation': chatSocket,
      'body': {
        {
          'phone': SharedPreferencesManager.getPhoneNumber(),
          'dest': widget.contact.phone
        }
      }
    })); // Scroll to the end of list
    setState(() {
      buildInitialList();
      // after 300 ms scroll down the list
      Timer(const Duration(milliseconds: 500), () {
        try {
          controller.jumpTo(controller.position.maxScrollExtent);
        } catch (e) {}
      });
    });
  }
}
