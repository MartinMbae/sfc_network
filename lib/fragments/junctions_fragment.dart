import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/junction_holder.dart';
import 'package:flutter_network/models/junction.dart';
import 'package:flutter_network/pages/empty_screen.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:outline_search_bar/outline_search_bar.dart';

class JunctionsPage extends StatefulWidget {
  @override
  _JunctionsPageState createState() => _JunctionsPageState();
}

class _JunctionsPageState extends State<JunctionsPage> {

  List<dynamic> initialJunctions;
  var scrollController = ScrollController();
  bool updating = false;
  
  bool showSearchResults = false;
  var searchTerm = "";
  

  @override
  void initState() {
    super.initState();
    getManholes();
  }

  getManholes() async {
    initialJunctions = await JunctionApiHelper().fetchJunctions(context, "0");
    setState(() {});
  }

  checkUpdate() async {
    setState(() {
      updating = true;
    });
    var scrollPosition = scrollController.position;
    if (scrollPosition.pixels == scrollPosition.maxScrollExtent) {
      List<dynamic> newIcsNews = await  JunctionApiHelper().fetchJunctions(context, "${initialJunctions.length}");
      initialJunctions.addAll(newIcsNews);
    }

    setState(() {
      updating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showSearchResults){
      return getSearchJunctionBody();
    }else {
      return getJunctionsBody();
    }
  }

  getJunctionsBody() {
    if (initialJunctions == null) return Center(child: CircularProgressIndicator());
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
            getSearchIcon(false, ""),
            Expanded(
              child: ListView.builder(
                itemCount: initialJunctions.length,
                shrinkWrap: true,
                controller: scrollController,
                itemBuilder: (context, index) {
                  return  JunctionHolder(
                    junction: Junction.fromJson(initialJunctions[index]),
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

  
  Future<String> fetchJunctions() async {
    await Future.delayed(Duration(seconds: 2));
    SessionManager prefs = SessionManager();
    var userId = await prefs.getId();
    var url = "${BASE_URL}index.php/v1/api/junctions";
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
      throw new Exception('Error fetching junctions');
    }

    return response.body;
  }



  getSearchIcon(bool showInitial, String initial){
    return  Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: OutlineSearchBar(
        initText: showInitial ? initial : "",
        hintText: "Search by junction name",
        onSearchButtonPressed: (key){
          searchTerm = key;
          setState(() {
            showSearchResults = true;
          });
        },
      ),
    );
  }

   getSearchJunctionBody() {
    return Column(
      children: [
        getSearchIcon(true, searchTerm),
        FutureBuilder(
          future: fetchSearchJunctions(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String response = snapshot.data;
              final decoded = jsonDecode(response) as Map;
              if (decoded.containsKey("success")) {
                var success = decoded['success'];
                if (!success) {
                  return EmptyPage(
                    height: 200.0,
                      icon: Icons.error, message: decoded['message']);
                } else {
                  List<dynamic> junctions =decoded['data'];
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
                }
              }else{
                return Container();
              }

            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ],
    );
  }

  Future<String> fetchSearchJunctions() async {
    await Future.delayed(Duration(seconds: 2));
    SessionManager prefs = SessionManager();
    var userId = await prefs.getId();
    var url = "${BASE_URL}index.php/v1/api/junctions";
    Map<String, String> queryParams = {
      'id': "$userId",
      'query': "$searchTerm"
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

    return response.body;
  }
  
}



class JunctionApiHelper {

  Future<List<dynamic>> fetchJunctions( BuildContext context, String start) async {

    var url = "${BASE_URL}index.php/v1/api/junctions";
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
      throw new Exception('Error fetching junctions');
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