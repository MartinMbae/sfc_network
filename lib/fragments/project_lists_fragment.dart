import 'dart:convert';

import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/models/project.dart';
import 'package:flutter_network/pages/empty_screen.dart';
import 'package:flutter_network/project_holder.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:http/http.dart' as http;

class ProjectListPage extends StatefulWidget {
  @override
  _ProjectListPageState createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {

  String condition = "all";
  Future<String> fetchProjects() async {
    var url = "${BASE_URL}index.php/v1/api/projectFetch/$condition";
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


    return Scaffold(
      appBar: AppBar(title: Text("Projects"),),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 30),
        child: Container(
          child: Column(
            children: [
              DropDownFormField(
                titleText: 'Sort Projects',
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
                  {
                    "text": "Sites",
                    "value": "Site",
                  },
                ],
                textField: 'text',
                valueField: 'value',
              ),
              Container(
                child: FutureBuilder(
                  future: fetchProjects(),
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
                          List<dynamic> projects =decoded['data'];
                          bool hasData = projects.length > 0;
                          return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                return hasData
                                    ? Column(
                                  children: [
                                    ProjectHolder(
                                      project: Project.fromJson(projects[index]),
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
