import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/manhole_holder.dart';
import 'package:flutter_network/models/cluster.dart';
import 'package:flutter_network/models/manhole.dart';
import 'package:flutter_network/pages/empty_screen.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class ManholeClusterPage extends StatefulWidget {

  final Cluster cluster;

  const ManholeClusterPage({Key key, @required this.cluster}) : super(key: key);

  @override
  _ManholeClusterPageState createState() => _ManholeClusterPageState();
}

class _ManholeClusterPageState extends State<ManholeClusterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manholes in ${widget.cluster.cluster_name}"),
      ),
      body: FutureBuilder(
        future: fetchManholesCLuster(widget.cluster.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> manhole = snapshot.data;
            bool hasData = manhole.length > 0;
            return ListView.builder(
                itemCount: manhole.length,
                itemBuilder: (context, index) {
                  return hasData
                      ? Column(
                          children: [
                            ManholeHolder(
                              manhole: Manhole.fromJson(manhole[index]),
                              num: index + 1,
                            ),
                            Divider(
                              color: Colors.black,
                            )
                          ],
                        )
                      : EmptyPage(
                          icon: Icons.error, message: "No manhole found");
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List<dynamic>> fetchManholesCLuster(String clusterId) async {
    await Future.delayed(Duration(seconds: 2));
    SessionManager prefs = SessionManager();
    var userId = await prefs.getId();
    var url = "${BASE_URL}index.php/v1/api/clustersroutes/$clusterId";
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
      throw new Exception('Error fetching manholes');
    }

    List<dynamic> manhole = json.decode(response.body);

    return manhole;
  }
}
