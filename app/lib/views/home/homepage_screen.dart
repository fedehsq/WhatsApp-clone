import 'package:flutter/material.dart';
import '../../main.dart';
import 'chat_tab_screen.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({Key? key}) : super(key: key);

  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> with TickerProviderStateMixin {
  late double screenWidth;

  @override
  void didChangeDependencies() {
    screenWidth = MediaQuery.of(context).size.width / 4.7;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        initialIndex: 1,
        length: 4,
        child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  title: const Text(
                    'WhatsApp',
                    style: TextStyle(color: textColor),
                  ),
                  actions: [
                    IconButton(
                        icon: const Icon(Icons.search), onPressed: () => {})
                  ],
                  backgroundColor: primaryColor,
                  floating: true,
                  pinned: true,
                  bottom: TabBar(
                    isScrollable: true,
                    unselectedLabelColor: textColor,
                    labelColor: secondaryColor,
                    tabs: <Widget>[
                      // tricky
                      const SizedBox(
                        width: 0,
                        height: 46,
                        child: Icon(
                          Icons.camera_alt,
                          size: 15,
                        ),
                      ),
                      Container(
                          width: screenWidth,
                          height: 46,
                          alignment: Alignment.center,
                          child: const Text("CHAT")),
                      Container(
                          width: screenWidth,
                          height: 46,
                          alignment: Alignment.center,
                          child: const Text("STATO")),
                      Container(
                          width: screenWidth,
                          height: 46,
                          alignment: Alignment.center,
                          child: const Text("CHIAMATE"))
                    ],
                  ),
                ),
              ];
            },
            body: const TabBarView(
              children: [
                Text(''),
                ChatTabScreen(),
                Text(''),
                Text(''),
              ],
            )),
      ),
    );
  }
}