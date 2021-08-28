import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/models/site.dart';
import 'package:flutter_network/site_holder.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class SitesPage extends StatefulWidget {
  @override
  _SitesPageState createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {

  List<dynamic> initialSites;
  var scrollController = ScrollController();
  bool updating = false;

  @override
  void initState() {
    super.initState();
    getManholes();
  }

  getManholes() async {
    initialSites = await SitesApiHelper().fetchSites(context, "0");
    setState(() {});
  }

  checkUpdate() async {
    setState(() {
      updating = true;
    });
    var scrollPosition = scrollController.position;
    if (scrollPosition.pixels == scrollPosition.maxScrollExtent) {
      List<dynamic> newIcsNews = await  SitesApiHelper().fetchSites(context, "${initialSites.length}");
      initialSites.addAll(newIcsNews);
    }

    setState(() {
      updating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return getSitesBody();
  }

  getSitesBody() {
    if (initialSites == null) return Center(child: CircularProgressIndicator());
    return NotificationListener<ScrollNotification>(
      onNotification: (noti) {
        if (noti is ScrollEndNotification) {
          checkUpdate();
        }
        return true;
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: initialSites.length,
                shrinkWrap: true,
                controller: scrollController,
                itemBuilder: (context, index) {
                  return  SiteHolder(
                    site: Site.fromJson(initialSites[index]),
                    num: index + 1,
                  );
                },
              ),
            ),
            if (updating) CircularProgressIndicator()
          ],
        ),
      ),
    );
  }

}


class SitesApiHelper {

  Future<List<dynamic>> fetchSites( BuildContext context, String start) async {

    var url = "${BASE_URL}index.php/v1/api/sites";
    SessionManager prefs = SessionManager();
    var userId = await prefs.getId();
    Map<String, String> queryParams = {
      'id': "$userId",
      'start':start,
      'limit':"20"
    };
    String queryString = Uri(queryParameters: queryParams).query;

    var requestUrl = url  + '?' + queryString;
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
    final decoded = jsonDecode(response.body) as Map;
    if (decoded.containsKey("success")) {
      var success = decoded['success'];
      if (success) {
        List<dynamic> sites = decoded['data'];
        return sites;
      }
    }
    return [];
  }
}
