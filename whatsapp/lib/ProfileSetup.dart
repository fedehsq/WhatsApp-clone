import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';
import 'Home.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File image;
  final picker = ImagePicker();

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 48.0, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Info profilo',
                  style: TextStyle(color: TEXT_COLOR, fontSize: FONT_SIZE),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Inserisci il tuo nome e (facoltativo) un\'immagine per il tuo',
                    style: TextStyle(color: Colors.grey,
                        fontSize: screenWidth <= MIN_WIDTH ? 12 : 14),
                  ),
                ),
                Center(
                  child: Text('profilo',
                    style: TextStyle(color: Colors.grey,
                        fontSize: screenWidth <= MIN_WIDTH ? 12 : 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: getImage,
                    child: SizedBox(
                      height: 90,
                      width: 90,
                      child: CircleAvatar(
                          backgroundImage: image != null ?
                          FileImage(image) : AssetImage(
                              'images/account.png')),
                    ),
                  ),
                ),
                Row(
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () =>
                {
                  /// Check for username
                  if (nameController.text.isNotEmpty) {
                    /// Start homepage
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (BuildContext context) => Home()),
                   (route) => false)
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Username!'))
                    )
                  }
                },
                child: Text(
                  'AVANTI', style: TextStyle(color: BACKGROUND_COLOR),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
