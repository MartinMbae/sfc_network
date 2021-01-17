import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_network/pages/splash_screen/splash_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() => runApp( MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return ScreenUtilInit(
      designSize: Size(360,690),
      allowFontScaling: false,
      child:  MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Network Manager',
        theme: ThemeData(
          primarySwatch: Colors.red,
          // visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home:  SplashScreen(),
      ),
    );
  }
}
