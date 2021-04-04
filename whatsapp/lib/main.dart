
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() {
  runApp(MyApp());
}

const Color primary = const Color.fromARGB(255, 16, 29, 36);
const Color textColor = const Color.fromARGB(255, 212, 214, 216);
const tab = '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t';
const privacyUrl = 'https://faq.whatsapp.com/general/security-and-privacy/'
    'were-updating-our-terms-and-privacy-policy?campaign_id=12619934356&extra_1'
    '=s%7Cc%7C509722853999%7Cb%7C%2Binformativa%20%2Bsulla%20%2Bprivacy%20%2'
    'Bwhatsapp%7C&placement=&creative=509722853999&keyword=%2Binformativa%20%'
    '2Bsulla%20%2Bprivacy%20%2Bwhatsapp&partner_id=googlesem&extra_2=campaignid'
    '%3D12619934356%26adgroupid%3D128540823988%26matchtype%3Db%26network%3Dg%26'
    'source%3Dnotmobile%26search_or_content%3Ds%26device%3Dc%26devicemodel%3D%'
    '26adposition%3D%26target%3D%26targetid%3Dkwd-1155687995954%26loc_physical'
    '_ms%3D1008539%26loc_interest_ms%3D%26feeditemid%3D%26param1%3D%26param2%3D';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp',
      theme: ThemeData(
        // rgba(16,29,36,255)
        scaffoldBackgroundColor: primary,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Benvenuto su WhatsApp',
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 36
              ),
            ),
            Image(
                height: 250,
                image: AssetImage('images/setup_logo.png')
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                  text: TextSpan(
                      text: 'Leggi l\'',
                      style: TextStyle(color: textColor),
                      children: [
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>
                                        Padding(
                                          padding: const EdgeInsets.only(top: 16.0),
                                          child: WebviewScaffold(

                                           // appBar: AppBar(title: Text('ciao'),),
                                              url: privacyUrl),
                                        )
                                    ),
                                  ),


                            text: 'informativa sulla privacy',
                            style: TextStyle(color: Colors.lightBlueAccent)
                        ),

                        TextSpan(
                            text: '. Tocca "Accetta e continua" ${tab}per accettare i ',
                            style: TextStyle(color: textColor)
                        ),
                        TextSpan(
                            text: 'Termini di servizio',
                            style: TextStyle(color: Colors.lightBlueAccent)
                        ),
                        TextSpan(
                            text: '.',
                            style: TextStyle(color: textColor)
                        )
                      ]
                  )
              ),
            )
          ],
        ),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
