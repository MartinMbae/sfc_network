import 'package:flutter/material.dart';


class SimpleRow extends StatelessWidget {

  final title, subtitle;

  const SimpleRow({Key key, @required this.title, @required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(text: "$title : ", style: TextStyle(color: Colors.deepPurple)),
          TextSpan(text: "$subtitle", style: TextStyle(color: Colors.deepPurple)),
        ],
      ),
    );
  }
}
