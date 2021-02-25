import 'dart:convert';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class UpdatePassword extends StatelessWidget {
  BuildContext mainContext;
  ArsProgressDialog progressDialog;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    TextEditingController oldPassController = new TextEditingController();
    TextEditingController newPassController = new TextEditingController();
    TextEditingController confirmPassController = new TextEditingController();
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));

    return Scaffold(
      appBar: AppBar(
        title: Text("Update Password"),
      ),
      body: Builder(builder: (context) {
        mainContext = context;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListView(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Change your Password",
                      style: TextStyle(
                          fontSize: 20, decoration: TextDecoration.underline),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: oldPassController,
                      decoration: new InputDecoration(
                        labelText: "Provide your old password",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                          borderSide: new BorderSide(),
                        ),
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if (val.length == 0) {
                          return "Password cannot be empty";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.visiblePassword,
                      style: new TextStyle(
                        fontFamily: "Poppins",
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: newPassController,
                      decoration: new InputDecoration(
                        labelText: "Provide your new password",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                          borderSide: new BorderSide(),
                        ),
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if (val.length == 0) {
                          return "Password cannot be empty";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.visiblePassword,
                      style: new TextStyle(
                        fontFamily: "Poppins",
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: confirmPassController,
                      decoration: new InputDecoration(
                        labelText: "Confirm new password",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                          borderSide: new BorderSide(),
                        ),
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if (val.length == 0) {
                          return "Password cannot be empty";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.visiblePassword,
                      style: new TextStyle(
                        fontFamily: "Poppins",
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.purple)),
                      onPressed: () async {
                        if (formKey.currentState.validate()) {
                          String newPass = newPassController.text;
                          String confirmPass = confirmPassController.text;
                          String oldPass = oldPassController.text;
                          print("Confirm Pas is $confirmPass");
                          if (newPass != confirmPass) {
                            Scaffold.of(mainContext).showSnackBar(SnackBar(
                                content:
                                    Text("Your new password failed to match")));
                          } else {
                            progressDialog.show();
                            SessionManager prefs = new SessionManager();
                            String userId = await prefs.getId();
                            var url =
                                "${BASE_URL}v1/api/updateUserPassword/$userId";
                            http.Response response = await http.put(url, body: {
                              'password': "$newPass",
                              'current_password': "$oldPass",
                            }).timeout(Duration(seconds: 30), onTimeout: () {
                              progressDialog.dismiss();
                              DangerAlertBox(
                                  context: context,
                                  messageText:
                                      "Action took so long. Please check your internet connection and try again.",
                                  title: "Error");
                              return null;
                            });
                            progressDialog.dismiss();
                            if (response == null) {
                              DangerAlertBox(
                                  context: context,
                                  messageText:
                                      "Unknown error occurred. Please check your internet connection and try again.",
                                  title: "Error");
                            } else {
                              print(response.body);
                              final decoded = jsonDecode(response.body) as Map;
                              if (decoded.containsKey("success")) {
                                var status = decoded['success'];
                                if (!status) {
                                  DangerAlertBox(
                                      context: context,
                                      messageText: decoded['message'],
                                      title: "Failed");
                                  return;
                                } else {
                                  SuccessAlertBox(
                                      context: context,
                                      messageText:
                                          "Your password has been changed successfully.",
                                      title: "Success");
                                }
                              }
                            }
                          }
                        }
                      },
                      color: Colors.deepPurple,
                      textColor: Colors.white,
                      child: Text("Update".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
