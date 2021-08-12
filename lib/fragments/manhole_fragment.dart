import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/manhole_holder.dart';
import 'package:flutter_network/models/manhole.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class ManholePage extends StatefulWidget {
  @override
  _ManholePageState createState() => _ManholePageState();
}

class _ManholePageState extends State<ManholePage> {

  List<dynamic> initialManholes;
  var scrollController = ScrollController();
  bool updating = false;

  @override
  void initState() {
    super.initState();
    getManholes();
  }

  getManholes() async {
    initialManholes = await NewsApiHelper().fetchNews(context, "0");
    setState(() {});
  }

  checkUpdate() async {
    setState(() {
      updating = true;
    });
    var scrollPosition = scrollController.position;
    if (scrollPosition.pixels == scrollPosition.maxScrollExtent) {
      List<dynamic> newIcsNews = await  NewsApiHelper().fetchNews(context, "${initialManholes.length}");
      initialManholes.addAll(newIcsNews);
    }

    setState(() {
      updating = false;
    });
  }

  getManholeBody() {
    if (initialManholes == null) return Center(child: CircularProgressIndicator());
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
                  itemCount: initialManholes.length,
                shrinkWrap: true,
                controller: scrollController,
                  itemBuilder: (context, index) {
                    return  ManholeHolder(
                          manhole: Manhole.fromJson(initialManholes[index]),
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


  @override
  Widget build(BuildContext context) {
    return getManholeBody();
  }

}


class NewsApiHelper {

  Future<List<dynamic>> fetchNews( BuildContext context, String start) async {

    var url = "${BASE_URL}index.php/v1/api/manhole";
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
      throw new Exception('Error fetching manholes');
    }

    List<dynamic> manholes = json.decode(response.body);

    return manholes;
  }


}

