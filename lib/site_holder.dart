import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/fragments/manhole_cluster_page.dart';
import 'package:flutter_network/models/cluster.dart';

import 'models/site.dart';

class SiteHolder extends StatelessWidget {

  final Site site;
  final int num;

  const SiteHolder({Key key,  @required this.site, @required this.num}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 300,
      width: size.width,
      color: Colors.white,
      padding: EdgeInsets.only(left: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 20),
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
                        TextSpan(text: site.name, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SimpleRow(title: "Location Level", subtitle:site.locationlevel),
                  SimpleRow(title: "Location System", subtitle:site.locationsystem),
                  SimpleRow(title: "Latitude", subtitle:site.latitude),
                  SimpleRow(title: "Longitude", subtitle:site.longitude),
                  SimpleRow(title: "Status", subtitle:site.status),
                  SimpleRow(title: "Status Date", subtitle:site.status_date),
                  SimpleRow(title: "Location Type", subtitle:site.locationtype),
                  SimpleRow(title: "Description", subtitle:site.description),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
