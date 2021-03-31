import 'dart:convert';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;



class ProjectPage extends StatefulWidget {
  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  int currentStep = 0;
  ScrollController c;

  String selection;
  String manhole_id, junction_id, site_id;
  TextEditingController descController = new TextEditingController();

  Future<List<dynamic>> fetchManholes(BuildContext context) async {
    SessionManager prefs = SessionManager();
    var userId = await prefs.getId();
    var url = "${BASE_URL}index.php/v1/api/manhole";
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

  Future<List<dynamic>> fetchJunctions(BuildContext context) async {
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

    final decoded = jsonDecode(response.body) as Map;
    if (decoded.containsKey("success")) {
      var success = decoded['success'];

      if (success) {
        List<dynamic> junctions = decoded['data'];
        return junctions;
      }
    }
  }


  Future<List<dynamic>> fetchSites(BuildContext context) async {
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

    final decoded = jsonDecode(response.body) as Map;
    if (decoded.containsKey("success")) {
      var success = decoded['success'];

      if (success) {
        List<dynamic> sites = decoded['data'];
        return sites;
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    c = new PageController();

    return  Scaffold(
          appBar: AppBar(title: Text("Add Project"),),
          body: PageView(
      physics: new NeverScrollableScrollPhysics(),
      controller: c,
      // controller: PageController(viewportFraction: 0.8),
      children: [
          Container(
          padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/project.png', width: 150, height: 150,),
          SizedBox(height: 30,),
          Text("Add a new Project".toUpperCase(), textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
          ),

          SizedBox(height: 30,),
          DropDownFormField(
            titleText: 'Select facility',
            hintText: 'Please choose one',
            value: selection,
            onSaved: (value) {
              setState(() {
                selection = value;
              });
            },
            onChanged: (value) {
              setState(() {
                selection = value;
              });
            },
            dataSource: [
              {
                "value": "Junction",
              },
              {
                "value": "Manhole",
              },
              {
                "value": "Site",
              },
            ],
            textField: 'value',
            valueField: 'value',
          ),
          SizedBox(
            height: 20,
          ),
          RaisedButton(
            color: Colors.green,
            child: Text(
              'Proceed',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (selection == null) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("You have not made any selection")));
              } else {
                c.animateTo(MediaQuery.of(context).size.width,
                    duration: new Duration(seconds: 1),
                    curve: Curves.easeIn);
              }
            },
          ),
        ],
      ),
    ),

          Container(
            color: Colors.red[200].withOpacity(0.2),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  selection == "Manhole"
                      ? FutureBuilder(
                          future: fetchManholes(context),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<dynamic> manholes = snapshot.data;
                              return DropDownFormField(
                                required: true,
                                titleText: 'Select manhole',
                                hintText: 'Please choose one',
                                value: manhole_id,
                                onSaved: (value) {
                                  setState(() {
                                    manhole_id = value;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    manhole_id = value;
                                  });
                                },
                                dataSource: manholes,
                                textField: 'manholename',
                                valueField: 'id',
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              );
                            }
                          })
                      : selection == "Junction"
                          ? FutureBuilder(
                              future: fetchJunctions(context),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<dynamic> junctions = snapshot.data;
                                  return DropDownFormField(
                                    required: true,
                                    titleText: 'Select junction',
                                    hintText: 'Please choose one',
                                    value: junction_id,
                                    onSaved: (value) {
                                      setState(() {
                                        junction_id = value;
                                      });
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        junction_id = value;
                                      });
                                    },
                                    dataSource: junctions,
                                    textField: 'component_name',
                                    valueField: 'id',
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              })
                          :
                      selection == "Site" ?
                      FutureBuilder(
                          future: fetchSites(context),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<dynamic> sites = snapshot.data;
                              return DropDownFormField(
                                required: true,
                                titleText: 'Select Site',
                                hintText: 'Please choose one',
                                value: site_id,
                                onSaved: (value) {
                                  setState(() {
                                    site_id = value;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    site_id = value;
                                  });
                                },
                                dataSource: sites,
                                textField: 'name',
                                valueField: 'id',
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              );
                            }
                          })
                          :
                  Text("Selection is $selection"),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    minLines: 3,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "* Required";
                      } else
                        return null;
                    },
                    controller: descController,
                    //validatePassword,        //Function to check validation
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton(
                        color: Colors.redAccent,
                        child: Text(
                          'Previous',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (selection == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("You have not made any selection")));
                          } else {
                            c.animateTo(0,
                                duration: new Duration(seconds: 1),
                                curve: Curves.easeOut);
                          }
                        },
                      ),
                      RaisedButton(
                        color: Colors.green,
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (junction_id == null && manhole_id == null && site_id == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text("Please select a $selection")));
                          }  else if (descController.text.isEmpty) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Please briefly describe the condition of the $selection")));
                          } else {
                            SessionManager prefs = SessionManager();
                            var id = await prefs.getId();
                            var siteId = manhole_id != null ? manhole_id : junction_id != null ? junction_id : site_id;
                            submitProject(selection, siteId, id, descController.text, context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
        );
  }



  Future<void> submitProject(
      String siteType,
      String siteId,
      String techId,
      String desc,
      BuildContext context) async {

    ArsProgressDialog progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));

    progressDialog.show();

    var url = BASE_URL + 'index.php/v1/api/project';

    var uri = Uri.parse(url);
    var request = new http.MultipartRequest("POST", uri);

    request.fields['tech_id'] = techId;
    request.fields['site_id'] = siteId;
    request.fields['site_type'] = siteType;
    request.fields['description'] = desc;

    var response = await request.send();
    progressDialog.dismiss();
    if (response.statusCode == 200) {
      response.stream.transform(utf8.decoder).listen((value) {
        Map<String, dynamic> responseMessage = jsonDecode(value);
        if (responseMessage.containsKey("success")) {
          bool success = responseMessage['success'];
          if (success) {
            descController.text = "";
            String message = responseMessage['message'];
            Navigator.pop(context);
            SuccessAlertBox(
                context: context, messageText: message, title: "Success");
          } else {
            String message = responseMessage['message'];
            DangerAlertBox(
                context: context, messageText: message, title: "Error");
          }
        }
      });
    } else {
      DangerAlertBox(
          context: context,
          messageText: "Something went wrong. Please try again.",
          title: "Error");
    }
  }
}
