import 'package:flutter/material.dart';


class EmptyPage extends StatelessWidget {

  final  icon;
  final String message;

  const EmptyPage({Key key, @required this.icon, @required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60,color: Colors.deepPurple,),
          SizedBox(height: 15,),
          Text(message, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.deepPurple),)
        ],
      ),
    );
  }
}
