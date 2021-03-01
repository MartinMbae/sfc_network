import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/fragments/manhole_cluster_page.dart';
import 'package:flutter_network/models/cluster.dart';

class ClusterHolder extends StatelessWidget {

  final Cluster cluster;
  final int num;

  const ClusterHolder({Key key,  @required this.cluster, @required this.num}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 80,
      width: size.width,
      color: Colors.white,
      padding: EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: new BoxDecoration(
                color: Colors.green[700],
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
                      TextSpan(text: cluster.cluster_name, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ],
                  ),
                ),
                SimpleRow(title: "Region", subtitle:cluster.region_id),

                GestureDetector(
                    child: Text("View manholes in this cluster", style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),),
                  onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ManholeClusterPage(
                        cluster: cluster,
                      )));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
