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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact),
        actions: [
          Icon(Icons.more_vert),
          Icon(Icons.call),
          Icon(Icons.video_call),
        ],
      ),
      body: CustomScrollView(
        reverse: true,
        slivers: [
          SliverFillRemaining(
            fillOverscroll: false,
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
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
                            chat.add(Container(color: PRIMARY_COLOR,
                                child: Text(
                                    messageController.text
                                    , style: TextStyle(color: TEXT_COLOR)
                                )
                            ));
                          });
                        },
                            icon: Icon(Icons.send, color: Colors.white))
                      ])
                ],
              ),
            ),
          ),
           SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                    Align(
                      alignment: index % 2 == 0
                          ? Alignment.centerRight
                          : Alignment
                          .centerLeft, child: chat[index],
                    ),
                childCount: chat.length,
              ),
            ),


        ],
      ),
    );
  }
}

/*
Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onSubmitted: (message) {
                  setState(() {
                    chat.add(Container(color: PRIMARY_COLOR,
                        child: Text(
                            debugString + debugString + debugString + debugString
                            , style: TextStyle(color: TEXT_COLOR)
                        )
                    ));
                  });

                },
                style: TextStyle(color: TEXT_COLOR),
                decoration: InputDecoration(
                  hintText: 'Scrivi un messaggio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
 */