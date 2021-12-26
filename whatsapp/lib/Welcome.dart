import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'main.dart';
import 'PhoneNumberSetup.dart';


class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Text(
                'Benvenuto su WhatsApp',
                style: TextStyle(
                    color: TEXT_COLOR,
                    fontWeight: FontWeight.bold,
                    fontSize: 32
                ),
              ),
            ),
            Image(
                height: 250,
                image: AssetImage('images/setup_logo.png')
            ),
            Column(
              children: [
                Center(
                  child: RichText(
                      text: TextSpan(
                          text: 'Leggi l\'',
                          style: TextStyle(color: TEXT_COLOR,
                              fontSize: screenWidth <= MIN_WIDTH
                                  ? MIN_INFO_FONT_SIZE
                                  : DEFAULT_INFO_FONT_SIZE),
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
                                                    url: PRIVACY_URL)
                                        ),
                                      ),
                                text: 'informativa sulla privacy',
                                style: TextStyle(color: URL_COLOR)
                            ),
                            TextSpan(
                                text: '. Tocca "Accetta e continua"',
                                style: TextStyle(
                                    color: TEXT_COLOR, fontSize: screenWidth <=
                                    MIN_WIDTH
                                    ? MIN_INFO_FONT_SIZE
                                    : DEFAULT_INFO_FONT_SIZE)
                            ),
                          ]
                      )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: RichText(
                        text: TextSpan(
                            text: ' per accettare i ',
                            style: TextStyle(color: TEXT_COLOR,
                                fontSize: screenWidth <= MIN_WIDTH
                                    ? MIN_INFO_FONT_SIZE
                                    : DEFAULT_INFO_FONT_SIZE),
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
                                                      url: TERMS_URL)
                                          ),
                                        ),
                                  text: 'termini di servizio',
                                  style: TextStyle(color: URL_COLOR)
                              ),
                              TextSpan(
                                  text: '.',
                                  style: TextStyle(color: TEXT_COLOR)
                              )
                            ]
                        )
                    ),
                  ),
                ),
                SizedBox(
                  width: 256,
                  child: ElevatedButton(onPressed: () =>
                  {
                    /// launch 2nd screen
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(
                            builder: (context) => PhoneNumber()), (
                            route) => false)
                  },
                    child: Text('ACCETTA E CONTINUA',
                      style: TextStyle(color: BACKGROUND_COLOR),
                    ),
                  ),
                ),
              ],
            ),

            Image(
                height: 30,
                image: AssetImage('images/from_fb.png'))
          ],
        ),
      ),
    );
  }
}
