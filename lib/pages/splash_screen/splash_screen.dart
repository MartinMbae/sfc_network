import 'package:flutter/material.dart';
import 'package:flutter_network/models/user.dart';
import 'package:flutter_network/pages/home_page.dart';
import 'package:flutter_network/pages/login.dart';
import 'package:flutter_network/utils/shared_pref.dart';

import 'animation_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    User loggedInUser;
    Future<User> getUserDetails() async {
      await Future.delayed(Duration(seconds: 3));
      SessionManager prefs = SessionManager();
           String firstName = await prefs.getFirstName();
      String lastName = await prefs.getLastName();
      String username = await prefs.getUsername();
      String email = await prefs.getEmail();
      String phone = await prefs.getPhone();
      String id = await prefs.getId();
      String role = await prefs.getRole();
      loggedInUser = User(
          id: id,
          firstName: firstName,
          lastName: lastName,
          username: username,
          email: email,
          phone: phone,
          role: role);
      return loggedInUser;
    }

    return Material(
        child: Stack(children: <Widget>[
      Scaffold(
          body: FutureBuilder(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User loggedInUser = snapshot.data;
            if(loggedInUser.username == null){
              return LoginPage();
            }else{
              return  HomePage(isEngineer:  loggedInUser.role == "2");
            }
          } else if (snapshot.hasError) {
            return LoginPage();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      )),
      IgnorePointer(
          child: AnimationScreen(color: Theme.of(context).accentColor))
    ]));
  }
}
