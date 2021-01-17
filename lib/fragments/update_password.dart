import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpdatePassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListView(
        children: [
          Column(
          children: [
            SizedBox(height: 15,),
            Text("Change your Password", style: TextStyle(fontSize: 20, decoration: TextDecoration.underline),),
            SizedBox(height: 15,),
            TextFormField(
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
            SizedBox(height: 15,),
            TextFormField(
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
            SizedBox(height: 15,),
            TextFormField(
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
            SizedBox(height: 15,),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.red)),
              onPressed: () {},
              color: Colors.red,
              textColor: Colors.white,
              child: Text("Update".toUpperCase(),
                  style: TextStyle(fontSize: 14)),
            ),
          ],
        )
        ],
      ),
    );
  }
}
