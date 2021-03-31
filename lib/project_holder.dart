import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/models/project.dart';

class ProjectHolder extends StatelessWidget {

  final Project project;
  final int num;

  const ProjectHolder({Key key,  @required this.project, @required this.num}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 130,
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
                  SimpleRow(title: "Site Type", subtitle:project.site_type),
                  SimpleRow(title: "Site Name", subtitle:project.site_name),
                  SimpleRow(title: "Description", subtitle:project.description),
                  SimpleRow(title: "Created By", subtitle:project.tech_name),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
