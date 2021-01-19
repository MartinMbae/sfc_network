import 'package:flutter_network/fragments/first_fragment.dart';
import 'package:flutter_network/fragments/report_incident.dart';
import 'package:flutter_network/fragments/second_fragment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_network/fragments/update_password.dart';
import 'package:flutter_network/models/user.dart';
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
    DrawerItem("Incident", Icons.dangerous),
     DrawerItem("Clusters", Icons.group_work),
     DrawerItem("Routes", Icons.router_outlined),
     DrawerItem("Junctions", Icons.link),
     DrawerItem("Customers", Icons.people_alt_outlined),
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
        return  UpdatePassword();
      case 3:
        return  ReportIncident();
      case 4:
        return  UpdatePassword();
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

    Future<User> getUserDetails() async{
      await Future.delayed(Duration(seconds: 3));
      SessionManager prefs = SessionManager();
      String firstName = await prefs.getFirstName();
      String lastName = await prefs.getLastName();
      String username = await prefs.getUsername();
      String email = await prefs.getEmail();
      String phone = await prefs.getPhone();
      int id = await prefs.getId();

      User loggedInUser = User(id: id, firstName: firstName, lastName: lastName, username: username, email: email, phone: phone );
      return loggedInUser;
    }

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
                  FutureBuilder(
                      builder: (context, snapshot){
                        if (snapshot.hasData){
                          User loggedInUser = snapshot.data;

                          print(loggedInUser.username);

                          return UserAccountsDrawerHeader(
                            accountName:  Text("${loggedInUser.firstName} ${loggedInUser.lastName}"),
                            accountEmail: Text("${loggedInUser.email}"),
                            currentAccountPicture: Image.asset('assets/net1.png'),
                          );
                        }else if (snapshot.hasError){
                          return UserAccountsDrawerHeader(
                            accountName:  Text("Error fetching..."),
                            accountEmail: Text("Error fetching"),
                            currentAccountPicture: Image.asset('assets/net1.png'),
                          );
                        }else{
                          return UserAccountsDrawerHeader(
                            accountName:  CircularProgressIndicator(),
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
        body: _getDrawerItemWidget(_selectedDrawerIndex),
      ),
    );
  }
}
