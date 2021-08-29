import 'dart:convert';
import 'dart:io';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:async/async.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path/path.dart';

class PatrolPage extends StatefulWidget {
  @override
  _PatrolPageState createState() => _PatrolPageState();
}

class _PatrolPageState extends State<PatrolPage> {
  int currentStep = 0;
  File _image;
  ScrollController c;

  String selection, condition;
  String manhole_name, junction_name;
  TextEditingController descController = new TextEditingController();
  TextEditingController junctionController = new TextEditingController();
  TextEditingController manholeController = new TextEditingController();

  String latitude, longitude;

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

  Future<LocationData> getLocationUpdates() async {
    Location location = new Location();

    bool _serviceEnabled;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
    _locationData = await location.getLocation();
    return _locationData;
  }

  @override
  Widget build(BuildContext context) {
    c = new PageController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Patrol"),
      ),
      body: PageView(
        physics: new NeverScrollableScrollPhysics(),
        controller: c,
        // controller: PageController(viewportFraction: 0.8),
        children: [
          FutureBuilder(
            future: getLocationUpdates(),
            builder: (builder, snapshot) {
              if (snapshot.hasData) {
                LocationData locationData = snapshot.data;
                latitude = "${locationData.latitude}";
                longitude = "${locationData.longitude}";
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/patrol.png'),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Report the status of the site elements".toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline),
                      ),
                      SizedBox(
                        height: 30,
                      ),
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
                                content:
                                    Text("You have not made any selection")));
                          } else {
                            c.animateTo(MediaQuery.of(context).size.width,
                                duration: new Duration(seconds: 1),
                                curve: Curves.easeIn);
                          }
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
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
                      ? TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Manhole Name',
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
                    controller: manholeController,
                    //validatePassword,        //Function to check validation
                  )
                      : selection == "Junction"
                          ? TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Junction Name',
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
                              controller: junctionController,
                              //validatePassword,        //Function to check validation
                            )
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
                      : Column(
                          children: [
                            Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Image.file(_image),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                            ),
                            GestureDetector(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Edit Image"),
                                ],
                              ),
                              onTap: getImage,
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
                          if (junctionController.text.isEmpty && manholeController.text.isEmpty) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text("Please select a $selection")));
                          } else if (condition == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Please select $selection's condition")));
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
                            var siteName =  manholeController.text.isEmpty ? junctionController.text : manholeController.text;
                            submitPatrollingMessage(
                                selection,
                                siteName,
                                id,
                                condition,
                                descController.text,
                                _image,
                                context);
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
      String siteType,
      String siteName,
      String techId,
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

    progressDialog.show();

    var url = BASE_URL + 'index.php/v1/api/patrolling';
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse(url);
    var request = new http.MultipartRequest("POST", uri);

    request.fields['tech_id'] = techId;
    request.fields['site_name'] = siteName;
    request.fields['site_type'] = siteType;
    request.fields['description'] = desc;
    request.fields['status'] = status;
    request.fields['longitude'] = longitude;
    request.fields['latitude'] = latitude;

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
