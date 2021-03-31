import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/cluster_holder.dart';
import 'package:flutter_network/models/cluster.dart';
import 'package:flutter_network/models/site.dart';
import 'package:flutter_network/pages/empty_screen.dart';
import 'package:flutter_network/site_holder.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class SitesPage extends StatefulWidget {
  @override
  _SitesPageState createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchSites(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String response = snapshot.data;
          final decoded = jsonDecode(response) as Map;
          if (decoded.containsKey("success")) {
            var success = decoded['success'];
            if (!success) {
              return EmptyPage(
                  icon: Icons.error, message: decoded['message']);
            } else {
              List<dynamic> sites =decoded['data'];
              bool hasData = sites.length > 0;
              return ListView.builder(
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    return hasData
                        ? Column(
                      children: [
                        SiteHolder(
                          site: Site.fromJson(sites[index]),
                          num: index + 1,
                        ),
                        Divider(
                          color: Colors.black,
                        )
                      ],
                    )
                        : EmptyPage(
                        icon: Icons.error, message: "No site found");
                  });
            }
          }else{
            return Container();
          }

        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<String> fetchSites() async {
    await Future.delayed(Duration(seconds: 2));
    SessionManager prefs = SessionManager();
    var userId = await prefs.getId();
    var url = "${BASE_URL}index.php/v1/api/sites";
    Map<String, String> queryParams = {
      'id': "$userId",
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
      throw new Exception('Error fetching sites');
    }
    return response.body;
  }
}
