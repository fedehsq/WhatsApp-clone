import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/api.dart';
import 'package:whatsapp_clone/managers/preference_manager.dart';
import 'package:whatsapp_clone/views/home/homepage_screen.dart';
import 'package:whatsapp_clone/main.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({Key? key}) : super(key: key);

  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  File? image;
  final picker = ImagePicker();

  // Connect to server
  final mainChannel = IOWebSocketChannel.connect(server);

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
          return const HomepageScreen();
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
                            fontSize: screenWidth <= mindWidth ? 11 : 14),
                      ),
                      Center(
                        child: Text(
                          'profilo',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: screenWidth <= mindWidth ? 11 : 14),
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
                      onPressed: () {
                        // Check for username
                        if (nameController.text.isNotEmpty) {
                          // save username and profile pic (optional)
                          SharedPreferencesManager.putData(
                              username, nameController.text);
                          if (image != null) {
                            SharedPreferencesManager.putData(
                                photo, base64.encode(image!.readAsBytesSync()));
                          } else {
                           // Load default pic
                            rootBundle
                                .load('images/default_profile_pic.png')
                                .then((bytes) {
                              SharedPreferencesManager.putData(photo,
                                  base64.encode(Uint8List.view(bytes.buffer)));
                            });
                          }
                          var json = {
                            'phone': SharedPreferencesManager.getPhoneNumber(),
                            'username': SharedPreferencesManager.getUsername(),
                            'photo': SharedPreferencesManager.getProfilePic()
                          };
                          // Send to the server
                          mainChannel.sink.add('REGISTER: ' + jsonEncode(json));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Inserisci il tuo username'),
                            duration: Duration(seconds: 1),
                          ));
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
