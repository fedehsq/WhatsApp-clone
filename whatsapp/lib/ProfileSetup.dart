import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

import 'main.dart';
import 'Home.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File image;
  final picker = ImagePicker();

  // Connect to server
  final mainChannel = IOWebSocketChannel.connect('ws://192.168.1.4:8080');

  final TextEditingController nameController = TextEditingController();

  /// Pick photo from internal storage
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: mainChannel.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          mainChannel.sink.close();
          return Home();
        }
        else
          return Scaffold(
              appBar: AppBar(
                backgroundColor: BACKGROUND_COLOR,
                elevation: 0.0,
                centerTitle: true,
                title: Text('Info profilo',
                  style: TextStyle(
                    color: TEXT_COLOR,),
                ),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Inserisci il tuo nome e (facoltativo) un\'immagine per il tuo',
                        style: TextStyle(color: Colors.grey,
                            fontSize: screenWidth <= MIN_WIDTH ? 12 : 14),
                      ),
                      Center(
                        child: Text('profilo',
                          style: TextStyle(color: Colors.grey,
                              fontSize: screenWidth <= MIN_WIDTH ? 12 : 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: InkWell(
                          onTap: getImage,
                          child: SizedBox(
                            height: 70,
                            width: 70,
                            child: CircleAvatar(
                                backgroundImage: image != null ?
                                FileImage(image) : AssetImage(
                                    'images/default_profile_pic.png')),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0, right: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                  controller: nameController,
                                  style: TextStyle(color: TEXT_COLOR),
                                  decoration: InputDecoration(
                                      hintText: 'Inserisci il tuo nome',
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: SECONDARY_COLOR
                                          )
                                      )
                                  )
                              ),
                            ),
                            Icon(Icons.emoji_emotions, color: TEXT_COLOR),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      onPressed: () =>
                      {
                        // Check for username
                        if (nameController.text.isNotEmpty) {
                          // save username and profile pic (optional)
                          SharedPreferences.getInstance().then((value) {
                            value.setString(USERNAME, nameController.text);
                            if (image != null) {
                              value.setString(
                                  PHOTO,
                                  base64.encode(image.readAsBytesSync()));
                              // Load default pic
                            } else {
                              rootBundle.load('images/default_profile_pic.png')
                                  .then((bytes) {
                                value.setString(
                                    PHOTO, base64.encode(
                                    Uint8List.view(bytes.buffer)));
                              });
                            }
                            var json = {
                              'phone': value.getString(PHONE_NUMBER),
                              'username': value.getString(USERNAME),
                              'photo': value.getString(PHOTO)
                            };
                            mainChannel.sink.add(
                                'REGISTER: ' + jsonEncode(json));
                          }),
                          // Send to the server

                        } else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Inserisci il tuo username'),
                                  duration: Duration(seconds: 1),
                                )
                            )
                          }
                      },
                      child: Text(
                        'AVANTI', style: TextStyle(color: BACKGROUND_COLOR),),
                    ),
                  )
                ],
              )
          );
      },
    );
  }
}
