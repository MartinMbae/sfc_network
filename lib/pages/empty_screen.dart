import 'package:flutter/material.dart';


class EmptyPage extends StatelessWidget {

  final  icon;
  final String message;
  final height;

  const EmptyPage({Key key, @required this.icon, @required this.message, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height == null ? MediaQuery.of(context).size.height : height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60,color: Colors.red,),
          SizedBox(height: 15,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(message, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),textAlign: TextAlign.center, ),
          )
        ],
      ),
    );
  }
}
