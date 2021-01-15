import 'package:flutter/material.dart';
import 'package:flutter_network/pages/login.dart';

class FirstFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Center(
      child:  FlatButton(
        onPressed: (){
          Navigator.push(  context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
        child: Row(
          children: [
            Icon(Icons.person_add),
            Text("Login"),

          ],
        ),
        color: Colors.blue[400],
      ),
    );
  }

}