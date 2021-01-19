import 'package:flutter/material.dart';
import 'package:flutter_network/fragments/first_fragment.dart';
import 'package:flutter_network/fragments/profile_page.dart';
import 'package:flutter_network/fragments/report_incident.dart';
import 'package:flutter_network/fragments/update_password.dart';
import 'package:flutter_network/models/user.dart';
import 'package:flutter_network/pages/login.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerItem {
  String title;
  IconData icon;
  String tag;
  DrawerItem({this.title, this.tag, this.icon});
}

class HomePage extends StatefulWidget {
  final drawerItems = [
    DrawerItem(title: "Dashboard", icon: Icons.dashboard, tag: DASHBOARD),
    DrawerItem(title: "Map", icon: Icons.map),
    DrawerItem(title: "Incident", icon: Icons.dangerous, tag: INCIDENTS),
    DrawerItem(title: "Profile", icon: Icons.person, tag: VIEW_PROFILE),
    DrawerItem(title: "Clusters", icon: Icons.group_work),
    DrawerItem(title: "Routes", icon: Icons.router_outlined),
    DrawerItem(title: "Junctions", icon: Icons.link),
    DrawerItem(title: "Customers", icon: Icons.people_alt_outlined),
    DrawerItem(title: "Patrolling", icon: Icons.policy_sharp),
    DrawerItem(title: "Network Design", icon: Icons.network_check),
    DrawerItem(title: "Settings", icon: Icons.settings),
    DrawerItem(title: "About the App", icon: Icons.info),
    DrawerItem(title: "Profile", icon: Icons.person),
    DrawerItem(title: "Log out", icon: Icons.logout, tag: LOGOUT),
  ];

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String selectedDrawerTag = DASHBOARD;
  int selectedDrawerIndex = 0;

  User loggedInUser;

  _getDrawerItemWidget(String drawer_tag) {
    switch (drawer_tag) {
      case DASHBOARD:
        return FirstFragment();
      case UPDATE_PROFILE:
        return UpdatePassword();
      case VIEW_PROFILE:
        return ProfilePage(loggedInUser: loggedInUser,);
      case INCIDENTS:
        return ReportIncident();
      default:
        return Text("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    List<Widget> drawerOptions = [];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(Column(
        children: [
          ListTile(
            leading: Icon(d.icon),
            title: Text(d.title),
            selected: d.tag == selectedDrawerTag,
            onTap: () async{
              if (d.tag == LOGOUT){
                SessionManager prefs = SessionManager();
                await prefs.logout();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                return;
              }

              setState(() {
                selectedDrawerTag = d.tag;
                selectedDrawerIndex = i;
              });
              Navigator.of(context).pop();
            },
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
        ],
      ));
    }
    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

    Future<User> getUserDetails() async {
      SessionManager prefs = SessionManager();
      String firstName = await prefs.getFirstName();
      String lastName = await prefs.getLastName();
      String username = await prefs.getUsername();
      String email = await prefs.getEmail();
      String phone = await prefs.getPhone();
      int id = await prefs.getId();
      loggedInUser = User(
          id: id,
          firstName: firstName,
          lastName: lastName,
          username: username,
          email: email,
          phone: phone);
      return loggedInUser;
    }

    return Scaffold(
      primary: true,
      appBar: AppBar(
        title: Text(widget.drawerItems[selectedDrawerIndex].title),
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
        drawer: Container(
          width: 240.w,
          child: Drawer(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        User loggedInUser = snapshot.data;
                        return UserAccountsDrawerHeader(
                          accountName: Text(
                              "${loggedInUser.firstName} ${loggedInUser.lastName}"),
                          accountEmail: Text("${loggedInUser.email}"),
                          currentAccountPicture: Image.asset('assets/net1.png'),
                        );
                      } else if (snapshot.hasError) {
                        return UserAccountsDrawerHeader(
                          accountName: Text("Error fetching..."),
                          accountEmail: Text("Error fetching"),
                          currentAccountPicture: Image.asset('assets/net1.png'),
                        );
                      } else {
                        return UserAccountsDrawerHeader(
                          accountName: CircularProgressIndicator(),
                          accountEmail: CircularProgressIndicator(),
                          currentAccountPicture: Image.asset('assets/net1.png'),
                        );
                      }
                    },
                    future: getUserDetails(),
                  ),
                  Column(children: drawerOptions)
                ],
              ),
            ),
          ),
        ),
        body:   _getDrawerItemWidget(selectedDrawerTag),
      ),
    );
  }
}
