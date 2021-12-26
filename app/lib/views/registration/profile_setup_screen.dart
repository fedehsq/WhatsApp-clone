import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/views/home/homepage_screen.dart';
import 'package:whatsapp_clone/main.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? image;
  final picker = ImagePicker();

  // Connect to server
  final mainChannel = IOWebSocketChannel.connect('ws://192.168.1.4:8080');

  final TextEditingController nameController = TextEditingController();

  /// Pick photo from internal storage
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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
          return HomepageScreen();
        } else {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: backgroundColor,
                elevation: 0.0,
                centerTitle: true,
                title: const Text(
                  'Info profilo',
                  style: TextStyle(
                    color: textColor,
                  ),
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
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: screenWidth <= mindWidth ? 12 : 14),
                      ),
                      Center(
                        child: Text(
                          'profilo',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: screenWidth <= mindWidth ? 12 : 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: InkWell(
                          onTap: getImage,
                          child: SizedBox(
                            height: 70,
                            width: 70,
                            child: image != null
                                ? CircleAvatar(
                                    backgroundImage: FileImage(image!))
                                : const CircleAvatar(
                                    backgroundImage: AssetImage(
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
                                  style: const TextStyle(color: textColor),
                                  decoration: const InputDecoration(
                                      hintText: 'Inserisci il tuo nome',
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: secondaryColor)))),
                            ),
                            const Icon(Icons.emoji_emotions, color: textColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      onPressed: () => {
                        // Check for username
                        if (nameController.text.isNotEmpty)
                          {
                            // save username and profile pic (optional)
                            SharedPreferences.getInstance().then((value) {
                              value.setString(username, nameController.text);
                              if (image != null) {
                                value.setString(photo,
                                    base64.encode(image!.readAsBytesSync()));
                                // Load default pic
                              } else {
                                rootBundle
                                    .load('images/default_profile_pic.png')
                                    .then((bytes) {
                                  value.setString(
                                      photo,
                                      base64.encode(
                                          Uint8List.view(bytes.buffer)));
                                });
                              }
                              var json = {
                                'phone': value.getString(phoneNumber),
                                'username': value.getString(username),
                                'photo': value.getString(photo)
                              };
                              mainChannel.sink
                                  .add('REGISTER: ' + jsonEncode(json));
                            }),
                            // Send to the server
                          }
                        else
                          {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Inserisci il tuo username'),
                              duration: Duration(seconds: 1),
                            ))
                          }
                      },
                      child: const Text(
                        'AVANTI',
                        style: TextStyle(color: backgroundColor),
                      ),
                    ),
                  )
                ],
              ));
        }
      },
    );
  }
}
