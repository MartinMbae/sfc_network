import 'dart:convert';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/Widget/bezierContainer.dart';
import 'package:flutter_network/pages/home_page.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ArsProgressDialog progressDialog;
  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: isPassword ? widget.passwordController : widget.usernameController,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget  _submitButton(BuildContext context) {
    return GestureDetector (
      onTap: () async{

        String username = widget.usernameController.text.trim();
        String password = widget.passwordController.text.trim();
        if(username.isEmpty || password.isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all the fields")));
          return;
        }
        progressDialog.show();
        http.Response response = await login(username,password);
        progressDialog.dismiss();
        if (response.statusCode == 200) {
          SessionManager prefs = SessionManager();
          final decoded = jsonDecode(response.body) as Map;
          //{"status":false,"message":"Username and password failed to match"}
          //{"success":true,"message":"Login successful","id":"1","first_name":"System","last_name":"Admin","email":"glob.admin","phone":"0987654567","created_at":"2019-03-01 09:31:01"}
          if (decoded.containsKey("status")){
            var status = decoded['status'];
            if (!status){
              DangerAlertBox(context: context, messageText: decoded['message'],title: "Failed");
              return;
            }
          }

          var firstName = decoded['first_name'];
          var id = decoded['id'];
          var lastName = decoded['last_name'];
          var email = decoded['email'];
          var phone = decoded['phone'];

          await prefs.setFirstName(firstName);
          await prefs.setLastName(lastName);
          await prefs.setEmail(email);
          await  prefs.setPhone(phone);
          await prefs.setUsername(username);
          await prefs.setId(int.parse(id));

          // Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => HomePage()));
          // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()));
          // Navigator.push(  context, MaterialPageRoute(builder: (context) => HomePage()));

          Navigator.pushAndRemoveUntil<dynamic>(context, MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => HomePage(),
            ),
                (route) => false,//if you want to disable back feature set to false
          );

        } else {
          DangerAlertBox(context: context, messageText: "Something went wrong. Please try again..",title: "Error");
        }

      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Future<http.Response>  login(username, password) async{
    var url = 'https://sfcfiber.co.ke/v1/api/login';
   return http.post(url,  body: {'username': "$username", 'pass': "$password"}).timeout(
            Duration(seconds: 30),
            onTimeout: () {
              progressDialog.dismiss();
              DangerAlertBox(context: context, messageText: "Action took so long. Please check your internet connection and try again.",title: "Error");
              return null;
            }
        );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'SFC',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: 'FIBER',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Username"),
        _entryField("Password", isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .2),
                  _title(),
                  SizedBox(height: 50),
                  _emailPasswordWidget(),
                  SizedBox(height: 20),
                  _submitButton(context),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: Text('Forgot Password ?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
