import 'dart:convert';
import 'dart:io';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_network/utils/sdb_resizer.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class ReportIncident extends StatefulWidget {
  @override
  _ReportIncidentState createState() => _ReportIncidentState();
}

class _ReportIncidentState extends State<ReportIncident> {
  File _image;

  String manhole_id;
  String maintenance_type_id;

  String latitude, longitude;

  TextEditingController crqController = new TextEditingController();
  TextEditingController descController = new TextEditingController();

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> submitIncidence(String techId, String crq, String desc,
      File imageFile, BuildContext context) async {
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

    var url = BASE_URL + 'index.php/v1/api/incidents';
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse(url);
    var request = new http.MultipartRequest("POST", uri);

    request.fields['tech_id'] = techId;
    request.fields['crq_no'] = crq;
    request.fields['manhole_id'] = manhole_id;
    request.fields['incident_desc'] = desc;
    request.fields['type'] = maintenance_type_id;
    request.fields['longitude'] = longitude;
    request.fields['latitude'] = latitude;

    var multipartFile = new http.MultipartFile(
      'incident_image',
      stream,
      length,
      filename: basename(imageFile.path),
    );

    request.files.add(multipartFile);
    var response = await request.send();
    progressDialog.dismiss(); //close dialog
    if (response.statusCode == 200) {
      response.stream.transform(utf8.decoder).listen((value) {
        Map<String, dynamic> responseMessage = jsonDecode(value);
        if (responseMessage.containsKey("success")) {
          bool success = responseMessage['success'];
          if (success) {
            crqController.text = "";
            descController.text = "";
            setState(() {
              _image = null;
            });
            String message = responseMessage['message'];
            SuccessAlertBox(
                context: context, messageText: message, title: "Success");
          } else {
            String message = responseMessage['message'];
            DangerAlertBox(
                context: context, messageText: message, title: "Error");
          }
        }

        print(value);
      });
    } else {
      DangerAlertBox(
          context: context,
          messageText: "Something went wrong. Please try again.",
          title: "Error");
    }
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

  Future<List<dynamic>> fetchTypes(BuildContext context) async {
    var url = "${BASE_URL}index.php/v1/api/types";
    var response =
        await http.get(url).timeout(Duration(seconds: 30), onTimeout: () {
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

    List<dynamic> types = json.decode(response.body);
    return types;
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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SDP.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Report Incidents"),
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
        child: ListView(
          children: [
            Column(
              children: <Widget>[
                Text(
                  "Report an Incident",
                  style: TextStyle(
                      fontSize: 20, decoration: TextDecoration.underline),
                ),
                SizedBox(
                  height: SDP.sdp(30),
                ),
                FutureBuilder(
                  future: getLocationUpdates(),
                  builder: (builder, snapshot) {
                    if (snapshot.hasData) {
                      LocationData locationData = snapshot.data;
                      latitude = "${locationData.latitude}";
                      longitude = "${locationData.longitude}";

                      return Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'CRQ Number',
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
                              //validatePassword,        //Function to check validation
                            ),
                            SizedBox(
                              height: SDP.sdp(30),
                            ),
                            FutureBuilder(
                                future: fetchManholes(context),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<dynamic> manholes = snapshot.data;
                                    return Container(
                                      child: DropDownFormField(
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
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                }),
                            SizedBox(
                              height: SDP.sdp(30),
                            ),
                            FutureBuilder(
                                future: fetchTypes(context),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<dynamic> types = snapshot.data;
                                    return Container(
                                      child: DropDownFormField(
                                        titleText:
                                        'Select maintenance type required',
                                        hintText: 'Please choose one',
                                        value: maintenance_type_id,
                                        onSaved: (value) {
                                          setState(() {
                                            maintenance_type_id = value;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            maintenance_type_id = value;
                                          });
                                        },
                                        dataSource: types,
                                        textField: 'type_name',
                                        valueField: 'id',
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                }),
                            SizedBox(
                              height: SDP.sdp(30),
                            ),
                            TextFormField(
                              controller: descController,
                              maxLength: 200,
                              maxLines: 5,
                              validator: (value) {
                                if (value.isEmpty) {
                                  print ("Error");
                                  return "* Required";
                                } else
                                  return null;
                              },
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                labelText: 'Describe the incident',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: SDP.sdp(30),
                            ),
                            _image == null
                                ?  GestureDetector(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
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
                                : Image.file(_image),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: MaterialButton(
                                color: Theme.of(context).accentColor,
                                child: Text(
                                  "Submit",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {


                                    if (maintenance_type_id == null || manhole_id  == null){

                                      Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text("Please Select all the fields"),
                                        duration: Duration(seconds: 3),
                                      ));
                                      return;
                                    }

                                    SessionManager prefs = SessionManager();
                                    var id = await prefs.getId();
                                    submitIncidence(id, crqController.text,
                                        descController.text, _image, context);
                                  } else {
                                    print("validation failed");
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
