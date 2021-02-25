import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/engineer_incident_holder.dart';
import 'package:flutter_network/models/engineer_incident.dart';
import 'package:flutter_network/pages/empty_screen.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:http/http.dart' as http;

class EngineerIncidentsPage extends StatefulWidget {
  @override
  _EngineerIncidentsPageState createState() => _EngineerIncidentsPageState();
}

class _EngineerIncidentsPageState extends State<EngineerIncidentsPage> {


  Future<List<dynamic>> fetchEngineerIncidents() async {
    var url = "${BASE_URL}index.php/v1/api/incidents";
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
      throw new Exception('Error fetching reported incidents');
    }

    List<dynamic> incidents = json.decode(response.body);

    return incidents;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchEngineerIncidents(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<dynamic> incidents = snapshot.data;
          bool hasData = incidents.length > 0;
          return ListView.builder(
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                return hasData
                    ? Column(
                        children: [
                          EngineerIncidentHolder(
                            engineerIncident: EngineerIncident.fromJson(incidents[index]),
                            num: index + 1,
                          ),
                          Divider(
                            color: Colors.grey,
                          )
                        ],
                      )
                    : EmptyPage(
                        icon: Icons.error, message: "No incidents found");
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

}
