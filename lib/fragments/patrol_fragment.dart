import 'dart:convert';
import 'dart:io';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';



class PatrolPage extends StatefulWidget {
  @override
  _PatrolPageState createState() => _PatrolPageState();
}

class _PatrolPageState extends State<PatrolPage> {
  int currentStep = 0;
  File _image;
  ScrollController c;

  String selection, condition;
  String manhole_id, junction_id;
  TextEditingController descController = new TextEditingController();

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    c = new PageController();

    return // IgnorePointer(
        Scaffold(
          appBar: AppBar(title: Text("Patrol"),),
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
                Image.asset('assets/patrol.png'),
                SizedBox(height: 30,),
                Text("Report the status of the site elements".toUpperCase(), textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                ),

                SizedBox(height: 30,),
                DropDownFormField(
                  titleText: 'Select element type',
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
                          : Text("Selection is $selection"),
                  SizedBox(
                    height: 20,
                  ),
                  DropDownFormField(
                    titleText: 'Select condition',
                    hintText: 'Please choose one',
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
                        "value": "Healthy",
                      },
                      {
                        "value": "Unhealthy but still functional",
                      },
                      {
                        "value": "Unhealthy & non-functional",
                      },
                    ],
                    textField: 'value',
                    valueField: 'value',
                  ),
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

                  _image == null
                      ? GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.add_a_photo),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Tap here to attach an image')
                            ],
                          ),
                          onTap: getImage,
                        )
                      :
                  Column(
                    children: [
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Image.file(_image),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      ),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 10,),
                            Text("Edit Image"),
                          ],
                        ),
                        onTap:getImage,
                      )
                    ],
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
                          if (junction_id == null && manhole_id == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text("Please select a $selection")));
                          } else if (condition == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text("Please select $selection's condition")));
                          } else if (descController.text.isEmpty) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Please briefly describe the condition of the $selection")));
                          } else if (_image == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text("Please attach an image")));
                          } else {
                            SessionManager prefs = SessionManager();
                            var id = await prefs.getId();

                            var siteId =
                                manhole_id == null ? junction_id : manhole_id;
                            submitPatrollingMessage(selection, siteId, id,
                                condition, descController.text, _image, context);
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

  Future<void> submitPatrollingMessage(
      String site_type,
      String site_id,
      String tech_id,
      String status,
      String desc,
      File imageFile,
      BuildContext context) async {
    if (imageFile == null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Please select an image"),
        duration: Duration(seconds: 3),
      ));
      return;
    }

    ArsProgressDialog progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));

    progressDialog.show(); // show dialog

    var url = BASE_URL + 'index.php/v1/api/patrolling';
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse(url);
    var request = new http.MultipartRequest("POST", uri);

    request.fields['tech_id'] = tech_id;
    request.fields['site_id'] = site_id;
    request.fields['site_type'] = site_type;
    request.fields['description'] = desc;
    request.fields['status'] = status;

    var multipartFile = new http.MultipartFile(
      'photo',
      stream,
      length,
      filename: basename(imageFile.path),
    );

    request.files.add(multipartFile);
    var response = await request.send();
    progressDialog.dismiss();
    if (response.statusCode == 200) {
      response.stream.transform(utf8.decoder).listen((value) {
        Map<String, dynamic> responseMessage = jsonDecode(value);
        if (responseMessage.containsKey("success")) {
          bool success = responseMessage['success'];
          if (success) {
            descController.text = "";
            setState(() {
              _image = null;
            });
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
