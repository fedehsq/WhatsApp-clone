import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Chat.dart';
import 'Welcome.dart';
import 'Home.dart';

void main() {
  runApp(MyApp());
}

const Color BACKGROUND_COLOR = const Color.fromARGB(255, 16, 29, 36);
const Color PRIMARY_COLOR = const Color.fromARGB(255, 35, 45, 54);
const Color TEXT_COLOR = const Color.fromARGB(255, 212, 214, 216);
const Color SECONDARY_COLOR = const Color.fromARGB(255, 0, 175, 156);
const Color URL_COLOR = const Color.fromARGB(255, 103, 185 , 226);
const PRIVACY_URL = 'https://faq.whatsapp.com/general/security-and-privacy/'
    'were-updating-our-terms-and-privacy-policy?campaign_id=12619934356&extra_1'
    '=s%7Cc%7C509722853999%7Cb%7C%2Binformativa%20%2Bsulla%20%2Bprivacy%20%2'
    'Bwhatsapp%7C&placement=&creative=509722853999&keyword=%2Binformativa%20%'
    '2Bsulla%20%2Bprivacy%20%2Bwhatsapp&partner_id=googlesem&extra_2=campaignid'
    '%3D12619934356%26adgroupid%3D128540823988%26matchtype%3Db%26network%3Dg%26'
    'source%3Dnotmobile%26search_or_content%3Ds%26device%3Dc%26devicemodel%3D%'
    '26adposition%3D%26target%3D%26targetid%3Dkwd-1155687995954%26loc_physical'
    '_ms%3D1008539%26loc_interest_ms%3D%26feeditemid%3D%26param1%3D%26param2%3D';

const TERMS_URL = 'https://www.whatsapp.com/legal/updates/terms-of-service/?lang=it';
const AGE_URL = 'https://faq.whatsapp.com/general/security-and-privacy/'
    'minimum-age-to-use-whatsapp/?lang=it';
const FB_URL = 'https://faq.whatsapp.com/general/security-and-privacy/'
    'how-we-work-with-the-facebook-companies?eea=1&lang=it';
const MIN_WIDTH = 360;
const PHONE_NUMBER = "com.example.whatsapp_clone.phoneNumber";
const USERNAME = "com.example.whatsapp_clone.username";
const PHOTO = "com.example.whatsapp_clone.photo";
const FONT_SIZE = 20.0;
var screenWidth;

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'WhatsApp',
        theme: ThemeData(
          scaffoldBackgroundColor: BACKGROUND_COLOR,
          primarySwatch: Colors.teal,
          primaryColor: SECONDARY_COLOR,
          hintColor: Colors.grey,
        ),
        home: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data.get(USERNAME) != null ? Chat(contact: 'Echo',) : Welcome();
              } else {
                return Scaffold(
                  body: Center(
                    child: Center(child: Image(
                      image: AssetImage('images/white_logo.png'), width: 64,)),
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Image(
                      image: AssetImage('images/from_fb.png'), height: 35,),
                  ),

                );
              }
            }
        ),


    );
  }
}

