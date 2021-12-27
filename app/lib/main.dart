import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/views/registration/welcome_screen.dart';

import 'managers/preference_manager.dart';
import 'views/home/homepage_screen.dart';

const Color backgroundColor = Color.fromARGB(255, 16, 29, 36);
const Color chatColor = Color.fromARGB(255, 5, 71, 64);
const Color primaryColor = Color.fromARGB(255, 35, 45, 54);
const Color textColor = Color.fromARGB(255, 212, 214, 216);
const Color secondaryColor = Color.fromARGB(255, 0, 175, 156);
const Color urlColor = Color.fromARGB(255, 103, 185, 226);
const privacyUrl = 'https://faq.whatsapp.com/general/security-and-privacy/'
    'were-updating-our-terms-and-privacy-policy?campaign_id=12619934356&extra_1'
    '=s%7Cc%7C509722853999%7Cb%7C%2Binformativa%20%2Bsulla%20%2Bprivacy%20%2'
    'Bwhatsapp%7C&placement=&creative=509722853999&keyword=%2Binformativa%20%'
    '2Bsulla%20%2Bprivacy%20%2Bwhatsapp&partner_id=googlesem&extra_2=campaignid'
    '%3D12619934356%26adgroupid%3D128540823988%26matchtype%3Db%26network%3Dg%26'
    'source%3Dnotmobile%26search_or_content%3Ds%26device%3Dc%26devicemodel%3D%'
    '26adposition%3D%26target%3D%26targetid%3Dkwd-1155687995954%26loc_physical'
    '_ms%3D1008539%26loc_interest_ms%3D%26feeditemid%3D%26param1%3D%26param2%3D';

const termsUrl =
    'https://www.whatsapp.com/legal/updates/terms-of-service/?lang=it';
const ageUrl = 'https://faq.whatsapp.com/general/security-and-privacy/'
    'minimum-age-to-use-whatsapp/?lang=it';
const fbUrl = 'https://faq.whatsapp.com/general/security-and-privacy/'
    'how-we-work-with-the-facebook-companies?eea=1&lang=it';

const mindWidth = 360;
const fontSize = 20.0;
const defaultIntroFontSize = 14.0;
const minInfoFontSize = 13.0;
late double screenWidth;

const phoneNumber = "com.example.whatsapp_clone.phoneNumber";
const username = "com.example.whatsapp_clone.username";
const photo = "com.example.whatsapp_clone.photo";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesManager.initalize();
  runApp(const WhatsApp());
}

class WhatsApp extends StatelessWidget {
  const WhatsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'WhatsApp',
        theme: ThemeData(
          scaffoldBackgroundColor: backgroundColor,
          primarySwatch: Colors.teal,
          primaryColor: secondaryColor,
          hintColor: Colors.grey,
        ),
        home: SharedPreferencesManager.getUsername() != null
            ? const HomepageScreen()
            : const WelcomeScreen());
  }
}
