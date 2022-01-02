import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/api.dart';
import 'package:whatsapp_clone/managers/preference_manager.dart';
import 'package:whatsapp_clone/views/contacts/contacts_screen.dart';
import '../../models/contact.dart';
import '../../models/message.dart';
import '../../main.dart';

/// Class representing the WhatsApp chat screen.
class Chat extends StatefulWidget {
  /// Indicates if the messages received must be added by this [Chat].
  /// (true only if the chat starts through [ContactsScreen]).
  final bool addMessage;

  /// The receiver [contact] of this [Chat].
  final Contact contact;

  const Chat({Key? key, required this.contact, required this.addMessage})
      : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with WidgetsBindingObserver {
  /// Manage user input.
  final TextEditingController messageController = TextEditingController();

  /// Connection with WhatsApp's [server].
  IOWebSocketChannel chatChannel = IOWebSocketChannel.connect(server);

  /// Manage scrolling: scroll down for every sent or received [Message].
  ScrollController controller = ScrollController();

  /// User's input.
  String input = '';

  /// Index of notification messages, so i know how to remove it in O(1)
  /// when tap ok keyboard
  int notifyPosition = -1;

  /// Avoid duplicated messages after a setState(() {}) invocation.
  var lastMessage = '';

  @override
  void initState() {
    // Get the peer's status
    chatChannel.sink.add(jsonEncode({
      'operation': chatSocket,
      'body': {
        'phone': SharedPreferencesManager.getPhoneNumber(),
        'dest': widget.contact.phone
      }
    }));
    // Scroll down when client enters the chat
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      controller.jumpTo(controller.position.maxScrollExtent);
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // Send online status to the server
      case AppLifecycleState.resumed:
        chatChannel = IOWebSocketChannel.connect(server);
        break;
      // Send offline status to the server (app yet opened in background)
      case AppLifecycleState.paused:
        chatChannel.sink.add(jsonEncode({
          'operation': offline,
          'body': {'phone': SharedPreferencesManager.getPhoneNumber()}
        }));
        chatChannel.sink.close();
        break;
      // On hard close app (remove from bg)
      default:
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
              if (snapshot.hasData && lastMessage != snapshot.data) {
                lastMessage = snapshot.data;
                // Converts byte message in string
                var json = jsonDecode(snapshot.data.toString());
                var responseOperation = json['operation'];
                log(responseOperation.toString());

                // Switch operations
                switch (responseOperation) {
                  // Client sends a message
                  case message:
                    var message = jsonDecode(json['body']['message']);
                    // Check if the received message comes from this peer
                    if (message['phone'] == widget.contact.phone) {
                      if (widget.addMessage) {
                        // Case in which this client starts the chat through ContactsScreen
                        widget.contact.messages
                            .add(Message(message['message'], fromServer: true));
                      } else {
                        // Message added in ChatScreenTab
                        SchedulerBinding.instance!.addPostFrameCallback((_) {
                          setState(() {});
                        });
                      }
                    }
                    break;
                  /*
                  // One or more message, while I am offline
                  case offlineMessages:
                    // How many messages have I received while I was offline?
                    int toRead = 0;
                    for (var message in json) {
                      toRead++;
                      var json = jsonDecode(message);
                      if (widget.contact.phone == body['phone']) {
                        Message m = Message(body['message'], true);
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
                    */

                  // A client comes offline
                  case offline:
                    var body = jsonDecode(json['body']['offline']);
                    // Check if it is the peer in this chat
                    if (widget.contact.phone == body['phone']) {
                      widget.contact.isOnline = false;
                    }
                    break;

                  // A client comes online
                  case online:
                    var body = jsonDecode(json['body']['online']);
                    log(body.toString());
                    // Check if it is the peer in this chat
                    if (widget.contact.phone == body['phone']) {
                      widget.contact.isOnline = true;
                    }
                    break;
                }
                // Scroll down
                SchedulerBinding.instance!.addPostFrameCallback((_) {
                  controller.jumpTo(controller.position.maxScrollExtent);
                });
              }
              return _buildChatStack();
            }));
  }

  /// Stack representing the WhatsApp's chat screen.
  Stack _buildChatStack() {
    return Stack(children: [
      const SingleChildScrollView(
        // Background image
        child: Opacity(
            opacity: 0.1,
            child: Padding(
              padding: EdgeInsets.only(top: 80.0),
              child: Image(image: AssetImage('images/chat_bg.png')),
            )),
      ),
      Column(
        children: [
          // Peer's info
          AppBar(
            backgroundColor: primaryColor,
            automaticallyImplyLeading: false,
            titleSpacing: 0.0,
            // Options to the left on the AppBar
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Left arrow
                SizedBox(
                    width: 32,
                    child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        // Remove the flag of notification from this chat
                        onPressed: () {
                          widget.contact.toRead = 0;
                          Navigator.pop(context, widget.contact);
                        })),
                // Peer's profile pic
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundImage: widget.contact.profileImage.image,
                    backgroundColor: primaryColor,
                  ),
                ),
                // Peer's status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.contact.username,
                        style: const TextStyle(fontSize: 17)),
                    if (widget.contact.isOnline)
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text('Online', style: TextStyle(fontSize: 10)),
                      )
                  ],
                ),
              ],
            ),
            // Options to the right on the AppBar
            actions: [
              IconButton(
                  onPressed: () => {},
                  icon: const Icon(Icons.videocam_rounded)),
              IconButton(onPressed: () => {}, icon: const Icon(Icons.call)),
              IconButton(
                  onPressed: () => {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          // List containig the messages
          Expanded(
            child: ListView.builder(
                controller: controller,
                itemCount: widget.contact.messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildMessageLayout(widget.contact.messages[index]);
                }),
          ),
          // TextField for user input and files buttons
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    /*onTap: () {
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
                       
                    }, */
                    /*
                    onChanged: (String value) {
                      / Set photo icon if text is empty
                      setState(() {});
                    }
                    */
                    maxLines: null,
                    // Goes to a new line after n char
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
                              icon: const Icon(Icons.photo_camera_rounded),
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
              // Send button
              Stack(alignment: Alignment.center, children: [
                const Icon(
                  Icons.circle,
                  color: secondaryColor,
                  size: 56,
                ),
                IconButton(
                    onPressed: () {
                      // Save user input
                      input = messageController.text;
                      if (input.isNotEmpty) {
                        widget.contact.messages
                            .add(Message(input, fromServer: false));
                        messageController.text = '';
                        // Encode message as Json object
                        setState(() {
                          // send to server
                          chatChannel.sink.add(jsonEncode({
                            'operation': send,
                            'body': {
                              'dest': widget.contact.phone,
                              'message': input
                            }
                          }));
                        });
                        SchedulerBinding.instance!.addPostFrameCallback((_) {
                          controller
                              .jumpTo(controller.position.maxScrollExtent);
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
  }

  /// Build [message] layout, checking where to place it.
  _buildMessageLayout(Message message) {
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
                          DateFormat('HH:mm')
                              .format(widget.contact.messages.last.timestamp),
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
}
