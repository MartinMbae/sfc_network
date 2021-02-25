import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/models/junction.dart';

class JunctionHolder extends StatelessWidget {

  final Junction junction;
  final int num;

  const JunctionHolder({Key key,  @required this.junction, @required this.num}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 260,
      width: size.width,
      color: Colors.white,
      padding: EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Container(
              margin: EdgeInsets.symmetric(vertical: 20),
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
                      TextSpan(text: junction.component_name, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ],
                  ),
                ),

                SimpleRow(title: "Type", subtitle:junction.comp_type),
                SimpleRow(title: "Category", subtitle: junction.category),
                SimpleRow(title: "Sub Category", subtitle: junction.subcategory),
                SimpleRow(title: "Owner", subtitle: junction.owner),
                SimpleRow(title: "Cluster", subtitle: junction.cluster_id),
                SimpleRow(title: "Technique", subtitle: junction.technique),
                SimpleRow(title: "aLocation", subtitle: junction.alocation),
                SimpleRow(title: "aLocation Description", subtitle: junction.alocationdesc),
                SimpleRow(title: "zLocation", subtitle: junction.zlocation),
                SimpleRow(title: "zLocation Description", subtitle: junction.zlocationdesc),
                SimpleRow(title: "Effective Length", subtitle: junction.effectivelength),
                SimpleRow(title: "Location Type", subtitle: junction.location_type),
                SimpleRow(title: "Status", subtitle: junction.status, subtitleColor: Colors.green[600],),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
