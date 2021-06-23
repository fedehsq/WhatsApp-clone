import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'ProfileSetup.dart';
import 'main.dart';


class PhoneNumber extends StatefulWidget {
  @override
  _PhoneNumberState createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  var countries = [
    "Italia", "USA", "UK", "Spagna", "Francia", "Non", "Sono",
    "Bravo", "in", "Geografia"
  ];
  var chosen = "Italia";
  final TextEditingController phone = TextEditingController();
  
  // Connect to server
  final mainChannel = IOWebSocketChannel.connect('ws://192.168.116.224:8080');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: BACKGROUND_COLOR,
          elevation: 0.0,
          centerTitle: true,
          title: Text('Inserisci il tuo numero di telefono:',
            style: TextStyle(
                color: TEXT_COLOR,
                fontSize: screenWidth <= MIN_WIDTH ? 16 : FONT_SIZE),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.more_vert, color: Colors.grey,),
            )
          ],
        ),
        body: StreamBuilder(
            stream: mainChannel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == "OK") {
                  mainChannel.sink.close();
                  // Save phone number to sharedPreferences
                  SharedPreferences.getInstance().then((value) {
                    value.setString(PHONE_NUMBER, phone.text);
                    // Start next route
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(
                            builder: (context) => Profile())
                        , (route) => false);
                  });
                }
              }
                /*else {
                  // Phone number already in use
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Numero già in uso.'),
                        duration: Duration(
                            seconds: 1),
                      ));
                }
              }
              */
              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Center(child: Text(
                            'WhatsApp invierà un SMS per verificare il tuo numero di ',
                            style: TextStyle(color: TEXT_COLOR),
                          )),
                        ),
                        Center(
                          child: RichText(
                              text: TextSpan(
                                  text: 'telefono. ',
                                  style: TextStyle(color: TEXT_COLOR),
                                  children: [
                                    TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                        'Qualcuno ha mai davvero cliccato qua?'),
                                                    duration: Duration(
                                                        seconds: 1),

                                                  )),
                                        text: ' Qual è il mio numero?',
                                        style: TextStyle(color: URL_COLOR)
                                    ),
                                  ]
                              )
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: Column(
                            children: [
                              FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: SECONDARY_COLOR)
                                      ),
                                    ),
                                    child: Center(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          iconEnabledColor: SECONDARY_COLOR,
                                          dropdownColor: PRIMARY_COLOR,
                                          value: chosen,
                                          onChanged: (String newValue) {
                                            setState(() {
                                              chosen = newValue;
                                            });
                                          },
                                          items: countries.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Center(
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                      color: TEXT_COLOR),),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: TextFormField(
                                        initialValue: ' 39',
                                        keyboardType: TextInputType.phone,
                                        style: TextStyle(color: TEXT_COLOR),
                                        decoration: InputDecoration(
                                          prefixText: '+',
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: SECONDARY_COLOR),
                                          ),
                                        )

                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: TextField(
                                        controller: phone,
                                        keyboardType: TextInputType.phone,
                                        style: TextStyle(color: TEXT_COLOR),
                                        decoration: InputDecoration(
                                          hintText: 'numero di telefono',
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: SECONDARY_COLOR),
                                          ),
                                        )
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Possibili costi per SMS applicati dal tuo gestore',
                            style: TextStyle(color: Colors.grey),),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(onPressed: () =>
                          {
                            /// CHECK PHONE NUMBER
                            if (phone.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: const Text(
                                          'Inserisci il tuo numero di telefono'
                                      )
                                  ))
                            } else
                              {
                                // Send registration request to the server
                                mainChannel.sink.add(
                                    'REQUEST: ' + jsonEncode({'phone': phone.text})
                                )}
                          },
                            child: Text('AVANTI',
                              style: TextStyle(color: BACKGROUND_COLOR),
                            ),
                          ),
                        ),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Devi avere ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth <= MIN_WIDTH ? 11 : 12),
                              children: [
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    WebviewScaffold(
                                                        appBar: AppBar(
                                                          toolbarHeight: 0,),
                                                        url: AGE_URL)
                                            ),
                                          ),
                                    text: 'almeno 16 anni ',
                                    style: TextStyle(
                                        color: URL_COLOR,
                                        fontSize: screenWidth <= MIN_WIDTH
                                            ? 11
                                            : 12)
                                ),
                                TextSpan(
                                  text: 'per registrarti. Scopri come WhatsApp lavora ',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenWidth <= MIN_WIDTH
                                          ? 11
                                          : 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Center(
                            child: RichText(text: TextSpan(text: 'con le ',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenWidth <= MIN_WIDTH
                                        ? 11
                                        : 12),
                                children: [
                                  TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WebviewScaffold(
                                                          appBar: AppBar(
                                                            toolbarHeight: 0,),
                                                          url: FB_URL)
                                              ),
                                            ),
                                      text: 'aziende di Facebook',
                                      style: TextStyle(
                                          color: URL_COLOR,
                                          fontSize: screenWidth <=
                                              MIN_WIDTH ? 11 : 12)
                                  )
                                ]
                            )
                            ),
                          ),
                        )
                      ],
                    ),
                  ]
              );
            })
    );
  }
}