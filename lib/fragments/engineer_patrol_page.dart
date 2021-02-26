import 'dart:convert';

import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/engineer_incident_holder.dart';
import 'package:flutter_network/models/engineer_incident.dart';
import 'package:flutter_network/models/patroll.dart';
import 'package:flutter_network/pages/empty_screen.dart';
import 'package:flutter_network/patrol_holder.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class EngineerPatrolPage extends StatefulWidget {
  @override
  _EngineerPatrolPageState createState() => _EngineerPatrolPageState();
}

class _EngineerPatrolPageState extends State<EngineerPatrolPage> {

  String condition = "all";
  Future<String> fetchEngineerPatrols() async {
    var url = "${BASE_URL}index.php/v1/api/patrolling/$condition";
    var response = await http.get(url).timeout(Duration(seconds: 30),
        onTimeout: () {
          DangerAlertBox(
              context: context,
              messageText:
              "Action took so long. Please check your internet connection and try again.",
              title: "Error");
          return null;
        });
    if (response.statusCode != 200) {
      throw new Exception('Error fetching reported patrols');
    }

    return response.body;
  }

  @override
  Widget build(BuildContext context) {


    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 30),
      child: Container(
        child: Column(
          children: [
            DropDownFormField(
              titleText: 'Sort Patrols',
              value: condition,
              onSaved: (value) {
                setState(() {
                  condition = value;
                });
              },
              onChanged: (value) {
                setState(() {
                  condition = value;
                });
              },
              dataSource: [
                {
                  "text": "All",
                  "value": "all",
                },
                {
                  "text": "Junctions",
                  "value": "Junction",
                },
                {
                  "text": "Manholes",
                  "value": "Manhole",
                },
              ],
              textField: 'text',
              valueField: 'value',
            ),
            Container(
              child: FutureBuilder(
                future: fetchEngineerPatrols(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done){
                    return buildLoader();
                  }
                  if (snapshot.hasData) {
                    String response = snapshot.data;
                    final decoded = jsonDecode(response) as Map;
                    if (decoded.containsKey("success")) {
                      var success = decoded['success'];
                      if (!success) {
                        return EmptyPage(
                            icon: Icons.error,
                            message: decoded['message'],
                          height: MediaQuery.of(context).size.height / 2,
                        );
                      } else {
                        List<dynamic> patrols =decoded['data'];
                        bool hasData = patrols.length > 0;
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                            itemCount: patrols.length,
                            itemBuilder: (context, index) {
                              return hasData
                                  ? Column(
                                children: [
                                  EngineerPatrolHolder(
                                    patrol: Patrol.fromJson(patrols[index]),
                                    num: index + 1,
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  )
                                ],
                              )
                                  : EmptyPage(
                                  icon: Icons.error, message: "No Patrols found");
                            });
                      }
                    }else{
                      return Container();
                    }
                  } else {
                    return buildLoader();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoader(){
    return Center(child: Padding(
      padding:  EdgeInsets.only(top: 50),
      child: CircularProgressIndicator(),
    ));
  }

}
