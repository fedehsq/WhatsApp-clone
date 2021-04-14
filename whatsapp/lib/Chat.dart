import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/InstantMessage.dart';
import 'Contact.dart';
import 'Message.dart';
import 'main.dart';

/// QUANDO TORNO INDIETRO CONTROLLO SE L'ORA LA QUALE SONO USCITO è > DELLA LAST CONTACT, SE è COSì, SWAPPO!

/// Represents the WhatsApp chat screen
class Chat extends StatefulWidget {
  final Contact contact;
  Chat({Key key, this.contact}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // for user input
  final TextEditingController messageController = TextEditingController();
  // connect to server when open a Chat Screen
  final IOWebSocketChannel chatChannel = IOWebSocketChannel
      .connect('ws://192.168.1.12:8080');
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
      backgroundColor: Color.fromARGB(255, 8, 24, 33),
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
                      // Remove the flag of notification from this chat
                      onPressed: () {
                        widget.contact.toRead = false;
                        Navigator.pop(context, widget.contact);
                      }
                  )
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundImage: widget.contact.profileImage.image,
                  //widget.contact.profileImage,
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
              // Add message of other client (check if the stream in new)
              if (snapshot.hasData && lastMessage != snapshot.data) {
                lastMessage = snapshot.data;
                var json = jsonDecode('${snapshot.data}'.split("MESSAGE_FROM: ")[1]);
                // I MUST ALSO CHECK THAT THE SENDER IS THE CONTACT WITH WHOM I AM IN THE CHAT!
                // BECAUSE ANYONE SEND ME A MESSAGE, I RECEIVE THAT!
                if (widget.contact.phone == json['phone']) {
                  Message m = Message(json['message'], true);
                  chatListView.add(
                      buildMessageLayout(m));
                }
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
                                  try {
                                    controller.jumpTo(
                                        controller.position.maxScrollExtent);
                                  } catch (e) {}
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
                                  onChanged: (String value) {
                                    // Set photo icon if text is empty
                                    setState(() {});
                                  },
                                  maxLines: null,
                                  // go down when reached tot char
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
                                        if (messageController.text.isEmpty)
                                          IconButton(
                                            icon: Icon(
                                                Icons.photo_camera_rounded),
                                            color: TEXT_COLOR,
                                            onPressed: () {},),
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
                                    String message = "SEND_TO: " + jsonMessage;
                                    setState(() {
                                      // send to server
                                      chatChannel.sink.add(message);
                                    });
                                    // after 300 ms scroll down the list
                                    Timer(Duration(milliseconds: 300), () {
                                      try {
                                        controller.jumpTo(
                                            controller.position
                                                .maxScrollExtent);
                                      } catch (e) {}
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
              child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Row(
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
                        // Very tricky
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 2),
                          child: Text(DateFormat('HH:mm').format(widget.contact.messages[widget.contact.messages.length - 1].timestamp),
                              style: TextStyle(
                                  color: Colors.transparent,
                                  fontSize: 10)
                          ),
                        ),
                        if (!message.fromServer)
                          Icon(Icons.done_all, color: Colors.transparent,
                              size: 16)
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 2),
                          child: Text(DateFormat('HH:mm').format(widget.contact.messages[widget.contact.messages.length - 1].timestamp),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10)
                          ),
                        ),
                        if (!message.fromServer)
                          Icon(Icons.done_all, color: Colors.blue, size: 16)
                      ],
                    ),
                  ])
          ),
        )
    );
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Tell to the server that I want to start a chat
  void setup() {
    first = !first;
    // Read from SharedPreferences
    SharedPreferences.getInstance().then((value) {
      var json = {'phone': value.getString(PHONE_NUMBER)};
      chatChannel.sink.add('OPEN_CHAT_SOCKET: ' + jsonEncode(json));
      setState(() {
        buildInitialList();
      });
    });
  }
}