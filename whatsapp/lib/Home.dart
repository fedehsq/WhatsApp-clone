
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'ChatList.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {


  var screenWidth;


  @override
  void didChangeDependencies() {
    screenWidth = MediaQuery
        .of(context)
        .size
        .width / 4.7;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        initialIndex: 1,
        length: 4,
        child: NestedScrollView(
            headerSliverBuilder: (BuildContext context,
                bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  title: Text('WhatsApp', style: TextStyle(color: TEXT_COLOR),),
                  actions: [
                    IconButton(icon: Icon(Icons.search), onPressed: () => {})
                  ],
                  backgroundColor: PRIMARY_COLOR,
                  floating: true,
                  pinned: true,
                  bottom: TabBar(
                    isScrollable: true,
                    unselectedLabelColor: TEXT_COLOR,
                    labelColor: SECONDARY_COLOR,
                    tabs: <Widget>[
                      // tricky
                      Container(
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
                          child: Text("CHAT")),
                      Container(
                          width: screenWidth,
                          height: 46,
                          alignment: Alignment.center,
                          child: Text("STATO")),
                      Container(
                          width: screenWidth,
                          height: 46,
                          alignment: Alignment.center,
                          child: Text("CHIAMATE"))
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                Text(''),
                ChatList(),
                Text(''),
                Text(''),
              ],
            )
        ),
      ),
    );
  }
}

