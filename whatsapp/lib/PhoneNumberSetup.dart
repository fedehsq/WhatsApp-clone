import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(top: 48.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('Inserisci il tuo numero di telefono:',
                        style: TextStyle(
                            color: TEXT_COLOR, fontSize: FONT_SIZE),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: RichText(
                            text: TextSpan(
                                text: 'WhatsApp invierà un SMS per verificare il tuo numero di ',
                                style: TextStyle(color: TEXT_COLOR),
                                children: [
                                  TextSpan(
                                      text: screenWidth > 360
                                          ? '$TAB telefono.'
                                          :
                                      'telefono.',
                                      style: TextStyle(color: TEXT_COLOR)
                                  ),
                                  TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                      'Qualcuno ha mai davvero cliccato qua?'),
                                                )),
                                      text: ' Qual è il mio numero?',
                                      style: TextStyle(color: Colors
                                          .lightBlueAccent)
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                      keyboardType: TextInputType.phone,
                                      style: TextStyle(color: TEXT_COLOR),
                                      decoration: InputDecoration(
                                        hintText: '+ 39',
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: SECONDARY_COLOR),
                                        ),
                                      )),
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
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        ElevatedButton(onPressed: () =>
                        {
                          /// CHECK PHONE NUMBER
                          if (phone.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: const Text(
                                        'Inserisci il tuo numero di telefono'
                                    )
                                ))
                          } else
                            {
                              /// Save phone number to sharedPreferences
                              SharedPreferences.getInstance().then((value) {
                                /// Start next route
                                Navigator.pushAndRemoveUntil(context,
                                    MaterialPageRoute(
                                        builder: (context) => Profile())
                                    , (route) => false);
                              }
                              )
                            }
                        },
                          child: Text('AVANTI',
                            style: TextStyle(color: BACKGROUND_COLOR),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8, bottom: 8, left: 26.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Devi avere ',
                              style: TextStyle(color: Colors.grey),
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
                                        color: Colors.lightBlueAccent)
                                ),
                                TextSpan(
                                  text: 'per registrarti. Scopri come WhatsApp lavora con le ',
                                  style: TextStyle(color: Colors.grey),
                                ),
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
                                        color: Colors.lightBlueAccent)
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }
}
