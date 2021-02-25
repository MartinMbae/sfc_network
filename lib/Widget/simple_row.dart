import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';


class SimpleRow extends StatelessWidget {

  final title, subtitle, subtitleColor;

  const SimpleRow({Key key, @required this.title, @required this.subtitle, this.subtitleColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Expanded(
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(text: "$title : ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            TextSpan(text: "$subtitle", style: TextStyle(color: subtitleColor == null ? Colors.deepPurple : subtitleColor)),
          ],
        ),
      ),
    );
  }
}


