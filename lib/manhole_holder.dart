import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/models/cluster.dart';
import 'package:flutter_network/models/manhole.dart';

class ManholeHolder extends StatelessWidget {

  final Manhole manhole;
  final int num;

  const ManholeHolder({Key key,  @required this.manhole, @required this.num}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 120,
      width: size.width,
      color: Colors.white,
      padding: EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: new BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: double.maxFinite,
              child: Center(
                child: Text("$num",
                  style: TextStyle(color: Colors.white),),
              )
          ),
          SizedBox(width: 10,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: manhole.manholename, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ],
                  ),
                ),
                SimpleRow(title: "Description", subtitle:manhole.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
