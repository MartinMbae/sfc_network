import 'package:flutter_network/fragments/first_fragment.dart';
import 'package:flutter_network/fragments/second_fragment.dart';
import 'package:flutter_network/fragments/third_fragment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_network/pages/login.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {
  final drawerItems = [
     DrawerItem("Dashboard", Icons.dashboard),
     DrawerItem("Map", Icons.local_pizza),
     DrawerItem("Clusters", Icons.group_work),
     DrawerItem("Routes", Icons.router_outlined),
     DrawerItem("Junctions", Icons.link),
     DrawerItem("Customers", Icons.people_alt_outlined),
     DrawerItem("Incident", Icons.dangerous),
     DrawerItem("Patrolling", Icons.policy_sharp),
     DrawerItem("Network Design", Icons.network_check),
     DrawerItem("Settings", Icons.settings),
     DrawerItem("About the App", Icons.info),
     DrawerItem("Profile", Icons.person),
     DrawerItem("Log out", Icons.logout),
  ];

  @override
  State<StatefulWidget> createState() {
    return  HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return  FirstFragment();
      case 1:
        return  SecondFragment();
      case 2:
        return  ThirdFragment();

      default:

        return  Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;


    List<Widget> drawerOptions = [];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(
          Column(
            children: [
              ListTile(
              leading:  Icon(d.icon),
              title:  Text(d.title),
              selected: i == _selectedDrawerIndex,
              onTap: () => _onSelectItem(i),
        ),
              Divider(
                height: 1,
                color: Colors.grey,
              ),
            ],
          )
      );
    }
    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

    SessionManager prefs = SessionManager();
    var firstName = prefs.getFirstName();
    var lastName = prefs.getLastName();
    var username = prefs.getUsername();
    var email = prefs.getEmail();
    var phone = prefs.getPhone();



    return  Scaffold(
      primary: true,
      appBar:  AppBar(
      title:  Text(widget.drawerItems[_selectedDrawerIndex].title),
          leading: IconButton(
              icon: Icon(Icons.dehaze),
              onPressed: () {
                if (_scaffoldKey.currentState.isDrawerOpen == false) {
                  _scaffoldKey.currentState.openDrawer();
                } else {
                  _scaffoldKey.currentState.openEndDrawer();
                }
              }),
    ),
      body: Scaffold(
        key: _scaffoldKey,
        drawer:  Container(
          width: 240.w,
          child: Drawer(
            child:  SingleChildScrollView(
              child: Column(
                children: <Widget>[
                   UserAccountsDrawerHeader(
                      accountName:  Text("$firstName $lastName ($username"),
                      accountEmail: Text("$email"),
                    currentAccountPicture: Image.asset('assets/net1.png'),
                  ),
                   Column(children: drawerOptions)
                ],
              ),
            ),
          ),
        ),
        body: _getDrawerItemWidget(_selectedDrawerIndex),
      ),
    );
  }
}
