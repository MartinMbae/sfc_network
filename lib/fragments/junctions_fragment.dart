import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/junction_holder.dart';
import 'package:flutter_network/models/junction.dart';
import 'package:flutter_network/pages/empty_screen.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class JunctionsPage extends StatefulWidget {
  @override
  _JunctionsPageState createState() => _JunctionsPageState();
}

class _JunctionsPageState extends State<JunctionsPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchJunctions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<dynamic> junctions = snapshot.data;
          bool hasData = junctions.length > 0;
          return ListView.builder(
              itemCount: junctions.length,
              itemBuilder: (context, index) {
                return hasData
                    ? Column(
                        children: [
                          JunctionHolder(
                            junction: Junction.fromJson(junctions[index]),
                            num: index + 1,
                          ),
                          Divider(
                            color: Colors.black,
                          )
                        ],
                      )
                    : EmptyPage(
                        icon: Icons.error, message: "No junctions found");
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<List<dynamic>> fetchJunctions() async {
    await Future.delayed(Duration(seconds: 2));
    SessionManager prefs = SessionManager();
    var user_id = await prefs.getId();
    var url = "${BASE_URL}index.php/v1/api/junctions";
    Map<String, String> queryParams = {
      'id': "$user_id",
    };
    String queryString = Uri(queryParameters: queryParams).query;

    var requestUrl = url + '?' + queryString;
    var response = await http.get(requestUrl).timeout(Duration(seconds: 30),
        onTimeout: () {
      DangerAlertBox(
          context: context,
          messageText:
              "Action took so long. Please check your internet connection and try again.",
          title: "Error");
      return null;
    });
    if (response.statusCode != 200) {
      throw new Exception('Error fetching junctions');
    }

    List<dynamic> junctions = json.decode(response.body);

    return junctions;
  }
}
