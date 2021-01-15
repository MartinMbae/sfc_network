import 'package:flutter/material.dart';
import 'package:flutter_network/pages/login.dart';

import 'animation_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(
            children: <Widget>[
              Scaffold(
                  body: LoginPage()
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