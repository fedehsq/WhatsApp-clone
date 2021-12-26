import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/main.dart';
import 'profile_setup_screen.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({Key? key}) : super(key: key);

  @override
  _PhoneNumberState createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  var countries = [
    "Italia",
    "USA",
    "UK",
    "Spagna",
    "Francia",
    "Non",
    "Sono",
    "Bravo",
    "in",
    "Geografia"
  ];
  String chosen = "Italia";
  final TextEditingController phone = TextEditingController();

  // Connect to server
  final mainChannel = IOWebSocketChannel.connect('ws://192.168.1.4:8080');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Inserisci il tuo numero di telefono:',
            style: TextStyle(
                color: textColor,
                fontSize: screenWidth <= mindWidth ? 16 : fontSize),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            )
          ],
        ),
        // Server will send "OK" in the case of a fresh phone number, otherwise "KO"
        body: StreamBuilder(
            stream: mainChannel.stream,
            builder: (context, snapshot) {
              log(snapshot.toString());
              if (snapshot.hasData) {
                if (snapshot.data == "OK") {
                  mainChannel.sink.close();
                  SharedPreferences.getInstance().then((value) {
                    value.setString(phoneNumber, phone.text);
                    // Start next route
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()),
                        (route) => false);
                  });
                  // ahah
                  return const Text('');
                } else {
                  // After build the column, show error message
                  WidgetsBinding.instance!.addPostFrameCallback((_) =>
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Numero già registrato.'),
                        duration: Duration(seconds: 1),
                      )));
                  return buildColumn();
                }
                // Phone number already registered
              } else {
                return buildColumn();
              }
            }));
  }

  buildColumn() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Center(
                child: Text(
              'WhatsApp invierà un SMS per verificare il tuo numero di ',
              style: TextStyle(color: textColor),
            )),
          ),
          Center(
            child: RichText(
                text: TextSpan(
                    text: 'telefono. ',
                    style: const TextStyle(color: textColor),
                    children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text('Qualcuno ha mai davvero cliccato qua?'),
                              duration: Duration(seconds: 1),
                            )),
                      text: ' Qual è il mio numero?',
                      style: const TextStyle(color: urlColor)),
                ])),
          ),
          SizedBox(
            width: 250,
            child: Column(
              children: [
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: secondaryColor)),
                      ),
                      child: Center(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            iconEnabledColor: secondaryColor,
                            dropdownColor: primaryColor,
                            value: chosen,
                            onChanged: (String? newValue) {
                              setState(() {
                                chosen = newValue!;
                              });
                            },
                            items: countries.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Center(
                                  child: Text(
                                    value,
                                    style: const TextStyle(color: textColor),
                                  ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 50,
                      child: TextFormField(
                          initialValue: ' 39',
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            prefixText: '+',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: secondaryColor),
                            ),
                          )),
                    ),
                    SizedBox(
                      width: 150,
                      child: TextField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            hintText: 'numero di telefono',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: secondaryColor),
                            ),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Possibili costi per SMS applicati dal tuo gestore',
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () {
                /// CHECK PHONE NUMBER
                if (phone.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      duration: Duration(seconds: 1),
                      content: Text('Inserisci il tuo numero di telefono')));
                } else {
                  // Send registration request to the server
                  mainChannel.sink
                      .add('REQUEST: ' + jsonEncode({'phone': phone.text}));
                  log('message');
                }
              },
              child: const Text(
                'AVANTI',
                style: TextStyle(color: backgroundColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: 'Devi avere ',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth <= mindWidth ? 11 : 12),
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WebviewScaffold(
                                          appBar: AppBar(
                                            toolbarHeight: 0,
                                          ),
                                          url: ageUrl)),
                                ),
                          text: 'almeno 16 anni ',
                          style: TextStyle(
                              color: urlColor,
                              fontSize: screenWidth <= mindWidth ? 11 : 12)),
                      TextSpan(
                        text: 'per registrarti. Scopri come WhatsApp lavora ',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: screenWidth <= mindWidth ? 11 : 12),
                      ),
                      TextSpan(
                          text: 'con le ',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: screenWidth <= mindWidth ? 11 : 12),
                          children: [
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WebviewScaffold(
                                                    appBar: AppBar(
                                                      toolbarHeight: 0,
                                                    ),
                                                    url: fbUrl)),
                                      ),
                                text: 'aziende di Facebook',
                                style: TextStyle(
                                    color: urlColor,
                                    fontSize:
                                        screenWidth <= mindWidth ? 11 : 12))
                          ])
                    ])),
          )
        ],
      ),
    ]);
  }
}
