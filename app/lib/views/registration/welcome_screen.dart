import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:whatsapp_clone/main.dart';
import 'phone_setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Benvenuto su WhatsApp',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 28),
            ),
            const Image(
                height: 250, image: AssetImage('images/setup_logo.png')),
            Column(
              children: [
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: 'Leggi l\'',
                        style: TextStyle(
                            color: textColor,
                            fontSize: screenWidth <= mindWidth
                                ? minInfoFontSize
                                : defaultIntroFontSize),
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
                                              url: privacyUrl)),
                                    ),
                              text: 'informativa sulla privacy',
                              style: const TextStyle(color: urlColor)),
                          TextSpan(
                              text: '. Tocca "Accetta e continua"',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth <= mindWidth
                                      ? minInfoFontSize
                                      : defaultIntroFontSize)),
                          TextSpan(
                              text: ' per accettare i ',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth <= mindWidth
                                      ? minInfoFontSize
                                      : defaultIntroFontSize),
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
                                                        url: termsUrl)),
                                          ),
                                    text: 'termini di servizio',
                                    style: const TextStyle(color: urlColor)),
                                const TextSpan(
                                    text: '.',
                                    style: TextStyle(color: textColor))
                              ])
                        ])),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: 256,
                    child: ElevatedButton(
                      onPressed: () => {
                        /// launch 2nd screen
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PhoneNumberSetup()),
                            (route) => false)
                      },
                      child: const Text(
                        'ACCETTA E CONTINUA',
                        style: TextStyle(color: backgroundColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Image(height: 30, image: AssetImage('images/from_fb.png'))
          ],
        ),
      ),
    );
  }
}
