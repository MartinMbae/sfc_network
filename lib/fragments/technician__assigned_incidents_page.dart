import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/models/engineer_incident.dart';
import 'package:flutter_network/pages/empty_screen.dart';
import 'package:flutter_network/technician_assigned_incident_holder.dart';
import 'package:flutter_network/technician_incident_holder.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class TechnicianAssignedIncidentsPage extends StatefulWidget {
  @override
  _TechnicianAssignedIncidentsPageState createState() =>
      _TechnicianAssignedIncidentsPageState();
}

class _TechnicianAssignedIncidentsPageState
    extends State<TechnicianAssignedIncidentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Assigned incidents"),
      ),
      body: FutureBuilder(
        future: fetchIncidents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            String response = snapshot.data;
            try {
              final decoded = jsonDecode(response) as Map;
              if (decoded.containsKey("success")) {
                String message = decoded['message'];
                return EmptyPage(icon: Icons.error, message: message);
              }
            } catch (e) {}

            List<dynamic> incidents = json.decode(response);

            bool hasData = incidents.length > 0;
            return ListView.builder(
                itemCount: incidents.length,
                itemBuilder: (context, index) {
                  return hasData
                      ? Column(
                          children: [
                            TechnicianAssignedIncidentHolder(
                              engineerIncident:
                                  EngineerIncident.fromJson(incidents[index]),
                            ),
                            Divider(
                              color: Colors.black,
                            )
                          ],
                        )
                      : EmptyPage(
                          icon: Icons.error,
                          message:
                              "You have not been assigned any incident yet");
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<String> fetchIncidents() async {
    await Future.delayed(Duration(seconds: 2));
    SessionManager prefs = SessionManager();
    var userId = await prefs.getId();
    var url = "${BASE_URL}index.php/v1/api/incidentsassignment/$userId";
    var response =
        await http.get(url).timeout(Duration(seconds: 30), onTimeout: () {
      DangerAlertBox(
          context: context,
          messageText:
              "Action took so long. Please check your internet connection and try again.",
          title: "Error");
      return null;
    });

    if (response == null) {
      throw new Exception('Error fetching incidents');
    }
    if (response.statusCode != 200) {
      throw new Exception('Error fetching incidents');
    }
    return response.body;
  }
}
