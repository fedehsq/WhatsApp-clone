import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'main.dart';

class DebugChat extends StatefulWidget {
  final String contact;


  const DebugChat({Key key, this.contact}) : super(key: key);
  @override
  _DebugChatState createState() => _DebugChatState();
}

class _DebugChatState extends State<DebugChat> {

  final TextEditingController messageController = TextEditingController();

  // aggiorno ad ogni invio/ricezione
  final chat = [];

  ScrollController controller = ScrollController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(       
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                  'images/account.png',
              ),
              backgroundColor: PRIMARY_COLOR,),
          )
          ,
          backgroundColor: PRIMARY_COLOR,
          title: Text(widget.contact),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8),
              child: Icon(Icons.videocam_rounded),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8),
              child: Icon(Icons.call),
            )
            ,Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8),
              child: Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Stack(
          children: [
            Opacity(
                opacity: 0.1,
                child: Image(image: AssetImage('images/chat_bg.png'))),
            Column(
            children: [
              Expanded( // CONTROLLO COL NUMERO DEGLI ELEMENTI SE COSTRUIRLA NPRMALE P REVERSED!
                child: ListView.builder(
                    controller: controller,
                    itemCount: chat.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Align(
                          alignment: index % 2 == 0
                              ? Alignment.topRight
                              : Alignment
                              .topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                constraints: BoxConstraints(maxWidth: 350),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: index % 2 == 0
                                      ? CHAT_COLOR
                                      : PRIMARY_COLOR,
                                ),
                                padding: EdgeInsets.all(8),
                                child: Text(
                                    chat[index],
                                    style: TextStyle(
                                        color: TEXT_COLOR,
                                    fontSize: 16)
                                )
                            ),
                          )
                      );
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
                            Icons.emoji_emotions, color: Colors.grey,),
                          contentPadding: EdgeInsets.only(left: 8),
                          hintText: 'Scrivi un messaggio',
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
                        Icon(Icons.circle, color: SECONDARY_COLOR, size: 56,
                        ),
                        IconButton(onPressed: () {
                          setState(() {
                            chat.add(messageController.text);
                          });

                          /// DELAY IS NECESSARY TO UPDATE LIST!
                          Timer(Duration(milliseconds: 50), () =>
                              controller.jumpTo(
                                  controller.position.maxScrollExtent));
                        },
                            icon: Icon(Icons.send, color: Colors.white))
                      ]
                  )
                ],
              ),
            ],
          ),
              ]
        )
    );
  }
}

/*

Align(
                      alignment: index % 2 == 0
                          ? Alignment.centerRight
                          : Alignment
                          .centerLeft, child: chat[index],
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
                            Icons.emoji_emotions, color: Colors.grey,),
                          contentPadding: EdgeInsets.only(left: 8),
                          hintText: 'Scrivi un messaggio',
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
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.circle, color: SECONDARY_COLOR,
                            ), iconSize: 56, onPressed: () {
                          setState(() {
                            chat.add(Container(color: PRIMARY_COLOR,
                                child: Text(
                                    messageController.text
                                    , style: TextStyle(color: TEXT_COLOR)
                                )
                            ));
                          });
                        }),
                        IconButton(onPressed: () {
                          setState(() {
                            chat.insert(0, Container(color: PRIMARY_COLOR,
                                child: Text(
                                    messageController.text
                                    , style: TextStyle(color: TEXT_COLOR)
                                )
                            ));
                          });
                        },
                            icon: Icon(Icons.send, color: Colors.white))
                      ]
                  )
                ],
              ),
 */