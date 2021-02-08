import 'package:flutter/material.dart';
import 'package:flutter_network/fragments/first_fragment.dart';
import 'package:flutter_network/fragments/junctions_fragment.dart';
import 'package:flutter_network/fragments/map_fragment.dart';
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
  FragmentMenu fragmentMenu;
  DrawerItem({@required this.title,@required  this.fragmentMenu, @required this.icon});
}

class HomePage extends StatefulWidget {
  final drawerItems = [
    DrawerItem(title: "Dashboard", icon: Icons.dashboard, fragmentMenu: FragmentMenu.DASHBOARD),
    DrawerItem(title: "Map", icon: Icons.map, fragmentMenu: FragmentMenu.MAP_FRAGMENT),
    DrawerItem(title: "Incident", icon: Icons.dangerous, fragmentMenu: FragmentMenu.INCIDENTS),
    DrawerItem(title: "Profile", icon: Icons.person, fragmentMenu: FragmentMenu.VIEW_PROFILE),
    DrawerItem(title: "Clusters", icon: Icons.group_work, fragmentMenu: FragmentMenu.ERROR),
    DrawerItem(title: "Routes", icon: Icons.router_outlined, fragmentMenu: FragmentMenu.ERROR),
    DrawerItem(title: "Junctions", icon: Icons.link, fragmentMenu: FragmentMenu.JUNCTIONS),
    DrawerItem(title: "Customers", icon: Icons.people_alt_outlined, fragmentMenu: FragmentMenu.ERROR),
    DrawerItem(title: "Settings", icon: Icons.settings, fragmentMenu: FragmentMenu.ERROR),
    DrawerItem(title: "About the App", icon: Icons.info, fragmentMenu: FragmentMenu.ERROR),
    DrawerItem(title: "Log out", icon: Icons.logout, fragmentMenu: FragmentMenu.LOGOUT),
  ];

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  FragmentMenu selectedDrawer = FragmentMenu.DASHBOARD;
  int selectedDrawerIndex = 0;

  User loggedInUser;

  _getDrawerItemWidget(FragmentMenu fragmentMenu) {
    switch (fragmentMenu) {
      case FragmentMenu.DASHBOARD:
        return FirstFragment();
      case FragmentMenu.UPDATE_PROFILE:
        return UpdatePassword();
      case FragmentMenu.VIEW_PROFILE:
        return ProfilePage(loggedInUser: loggedInUser,);
      case FragmentMenu.INCIDENTS:
        return ReportIncident();
      case FragmentMenu.MAP_FRAGMENT:
        return MapFragment();
      case FragmentMenu.LOGOUT:
        break;
      case FragmentMenu.ERROR:
        return Text("Not Implemmented");
        break;
      case FragmentMenu.JUNCTIONS:
        return JunctionsPage();
        break;
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
            selected: d.fragmentMenu == selectedDrawer,
            onTap: () async{
              if (d.fragmentMenu == FragmentMenu.LOGOUT){
                SessionManager prefs = SessionManager();
                await prefs.logout();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                return;
              }

              setState(() {
                selectedDrawer = d.fragmentMenu;
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

    return WillPopScope(
      onWillPop: () async {
       if (selectedDrawer == FragmentMenu.DASHBOARD)
        return true;
       else {
         setState(() {
           selectedDrawer = FragmentMenu.DASHBOARD ;
           selectedDrawerIndex = 0;
         });
         return false;
       }
      },

      child: Scaffold(
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
          body:   _getDrawerItemWidget(selectedDrawer),
        ),
      ),
    );
  }
}
