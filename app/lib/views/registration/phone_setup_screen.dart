import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/api.dart';
import 'package:whatsapp_clone/main.dart';
import 'package:whatsapp_clone/managers/preference_manager.dart';
import 'profile_setup_screen.dart';

class PhoneNumberSetup extends StatefulWidget {
  const PhoneNumberSetup({Key? key}) : super(key: key);

  @override
  _PhoneNumberSetupState createState() => _PhoneNumberSetupState();
}

class _PhoneNumberSetupState extends State<PhoneNumberSetup> {
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
  final mainChannel = IOWebSocketChannel.connect(server);

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
              if (snapshot.hasData) {
                var response = jsonDecode(snapshot.data.toString());
                if (response['status_code'] == resultOk) {
                  mainChannel.sink.close();
                  SharedPreferencesManager.putData(phoneNumber, phone.text);
                  // Start next route
                  SchedulerBinding.instance!.addPostFrameCallback((_) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileSetup()),
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
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text:
                      'WhatsApp invierà un SMS per verificare il tuo numero di telefono.',
                  style: const TextStyle(color: textColor),
                  children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Qualcuno ha mai davvero cliccato qua?'),
                                duration: Duration(seconds: 1),
                              )),
                        text: ' Qual è il mio numero?',
                        style: const TextStyle(color: urlColor)),
                  ])),
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
                  mainChannel.sink.add(jsonEncode({
                    'operation': registrationRequest,
                    'body': {'phone': phone.text}
                  }));
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
