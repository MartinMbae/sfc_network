import 'package:flutter/material.dart';
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
  Widget build(BuildContext context){

    Future<bool> isLoggedIn() async{
      await Future.delayed(Duration(seconds: 3));
      SessionManager prefs = SessionManager();
      bool isLoggedIn = await prefs.getUsername() != null ? true : false;
      return isLoggedIn;
    }

    return Material(
        child: Stack(
            children: <Widget>[
              Scaffold(
                  body: FutureBuilder(
                    future: isLoggedIn(),
                    builder: (context, snapshot){
                      if(snapshot.hasData) {
                       return snapshot.data ?  HomePage() :  LoginPage();
                      } else if(snapshot.hasError) {
                        return LoginPage();
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
        )
              ),
              IgnorePointer(
                  child: AnimationScreen(
                      color: Theme.of(context).accentColor
                  )
              )
            ]
        )
    );
  }
}