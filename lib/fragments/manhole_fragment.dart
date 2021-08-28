import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/manhole_holder.dart';
import 'package:flutter_network/models/manhole.dart';
import 'package:flutter_network/pages/empty_screen.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:outline_search_bar/outline_search_bar.dart';

class ManholePage extends StatefulWidget {
  @override
  _ManholePageState createState() => _ManholePageState();
}

class _ManholePageState extends State<ManholePage> {

  List<dynamic> initialManholes;
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
    initialManholes = await ManholeApiHelper().fetchManholes(context, "0");
    setState(() {});
  }

  checkUpdate() async {
    setState(() {
      updating = true;
    });
    var scrollPosition = scrollController.position;
    if (scrollPosition.pixels == scrollPosition.maxScrollExtent) {
      List<dynamic> newIcsNews = await  ManholeApiHelper().fetchManholes(context, "${initialManholes.length}");
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
           getSearchIcon(false, ""),
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
    if(showSearchResults){
      return getSearchManholeBody();
    }else{
      return getManholeBody();
    }
  }
  
  getSearchManholeBody(){
   return Column(
     children: [
       getSearchIcon(true, searchTerm),
       FutureBuilder(
          future: fetchManholes(),
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
                      height: 200.0,
                        icon: Icons.error, message: "No manhole found with the provided name");
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
     ],
   );
  }

  Future<List<dynamic>> fetchManholes() async {
    await Future.delayed(Duration(seconds: 2));
    SessionManager prefs = SessionManager();
    var userId = await prefs.getId();
    var url = "${BASE_URL}index.php/v1/api/manhole";
    Map<String, String> queryParams = {
      'id': "$userId",
      'query' : "$searchTerm"
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

  getSearchIcon(bool showInitial, String initial){
    return  Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: OutlineSearchBar(
        initText: showInitial ? initial : "",
        hintText: "Search by manhole name",
        onSearchButtonPressed: (key){
          searchTerm = key;
          setState(() {
            showSearchResults = true;
          });
        },
      ),
    );
  }
}


class ManholeApiHelper {

  Future<List<dynamic>> fetchManholes( BuildContext context, String start) async {

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

