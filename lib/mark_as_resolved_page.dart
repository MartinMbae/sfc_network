import 'dart:convert';
import 'dart:io';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path/path.dart';

class MarkAsResolved extends StatefulWidget {

  final incidentId;
  final assignmentId;

  const MarkAsResolved({Key key, @required this.incidentId, @required this.assignmentId,}) : super(key: key);

  @override
  _MarkAsResolvedState createState() => _MarkAsResolvedState();
}

class _MarkAsResolvedState extends State<MarkAsResolved> {

  File _image;

  String latitude, longitude;

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

  final _formKey = GlobalKey<FormState>();


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
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
        child: Container(
          child: FutureBuilder(
            future: getLocationUpdates(),
            builder: (context, snapshot){
              if (snapshot.hasData) {
                LocationData locationData = snapshot.data;
                latitude = "${locationData.latitude}";
                longitude = "${locationData.longitude}";
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text("Mark as resolved", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, decoration: TextDecoration.underline), textAlign: TextAlign.center,),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: descController,
                        maxLength: 200,
                        maxLines: 5,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "* Required";
                          } else
                            return null;
                        },
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          labelText: 'Add a brief comment on the incident',
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
                        height: 30,
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
                              SessionManager prefs = SessionManager();
                              var id = await prefs.getId();
                              submitResolved(id,
                                  descController.text, _image, context);
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
        ),
      ),
    );
  }


  Future<void> submitResolved(String techId, String desc,
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

    var url = BASE_URL + 'index.php/v1/api/assignmentAction/${widget.assignmentId}/${widget.incidentId}';
    var stream =
    new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse(url);
    var request = new http.MultipartRequest("PUT", uri);

    request.fields['tech_id'] = techId;
    request.fields['comment'] = desc;
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
    progressDialog.dismiss(); //close dialog
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
