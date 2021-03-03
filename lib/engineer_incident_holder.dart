import 'dart:convert';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/models/engineer_incident.dart';
import 'package:flutter_network/utils/constants.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class EngineerIncidentHolder extends StatefulWidget {
  final EngineerIncident engineerIncident;
  final int num;

  const EngineerIncidentHolder(
      {Key key, @required this.engineerIncident, @required this.num})
      : super(key: key);

  @override
  _EngineerIncidentHolderState createState() => _EngineerIncidentHolderState();
}

class _EngineerIncidentHolderState extends State<EngineerIncidentHolder> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  ArsProgressDialog progressDialog;

  String newStatus = "";

  @override
  Widget build(BuildContext context) {
    String heroTag = "imageHero${widget.engineerIncident.incident_id}";

    Size size = MediaQuery.of(context).size;
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));

    return FlipCard(
      key: cardKey,
      flipOnTouch: false,
      front: Container(
        height: 180,
        width: size.width,
        color: Colors.white,
        padding: EdgeInsets.only(left: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(right: 10),
          child: Row(
            children: [
              Container(
                width: size.width / 3,
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: GestureDetector(
                      child: Hero(
                        tag: heroTag,
                        child: CachedNetworkImage(
                          imageUrl: widget.engineerIncident.incident_image,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Center(child: Icon(Icons.error)),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return SingleImageScreen(
                              tag: heroTag,
                              imageUrl: widget.engineerIncident.incident_image);
                        }));
                      }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleRow(
                        title: "CRQ Number",
                        subtitle: widget.engineerIncident.crq_no),
                    SimpleRow(
                        title: "Man hole",
                        subtitle: widget.engineerIncident.manhole_name),
                    SimpleRow(
                        title: "Incident Type",
                        subtitle: widget.engineerIncident.incident_type),
                    SimpleRow(
                        title: "Incident Description",
                        subtitle: widget.engineerIncident.incident_desc),
                    SimpleRow(
                        title: "Reported By",
                        subtitle: widget.engineerIncident.tech_id),
                    SimpleRow(
                      title: "Status",
                      subtitle: widget.engineerIncident.status,
                      subtitleColor:
                          widget.engineerIncident.status == "Approved"
                              ? Colors.green
                              : widget.engineerIncident.status == "Pending"
                                  ? Colors.black
                                  : Colors.red,
                    ),
                    RaisedButton(
                      color: Colors.green[600],
                      onPressed: () => cardKey.currentState.toggleCard(),
                      child: Text(
                        'Action',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
      back: Center(
        child: Container(
          height: 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SimpleRow(
                title: "Current Status",
                subtitle: widget.engineerIncident.status,
                subtitleColor: widget.engineerIncident.status == "Approved"
                    ? Colors.green
                    : widget.engineerIncident.status == "Pending"
                        ? Colors.black
                        : Colors.red,
              ),
              DropDownFormField(
                titleText: 'Select status',
                hintText: 'Please choose one',
                value: newStatus,
                onSaved: (value) {
                  setState(() {
                    newStatus = value;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    newStatus = value;
                  });
                },
                dataSource: [
                  {
                    "value": "Resolved",
                  },
                  {
                    "value": "Closed",
                  },

                ],
                textField: 'value',
                valueField: 'value',
              ),
              RaisedButton(
                color: Colors.green[600],
                onPressed: () {
                  if(newStatus == null || newStatus.isEmpty){
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("You have not made any selection")));
                    return;
                  }
                  cardKey.currentState.toggleCard();
                  ConfirmAlertBox(
                      context: context,
                      infoMessage:
                      "Confirm changing status to '$newStatus'?",
                      onPressedYes: () async {
                        Navigator.pop(context);
                        progressDialog.show();
                        SessionManager prefs = new SessionManager();
                        String userId = await prefs.getId();
                        var url =
                            "${BASE_URL}v1/api/incidentAction/${widget.engineerIncident.incident_id}";
                        http.Response response = await http.put(url, body: {
                          'engineer_id': "$userId",
                          'status': "Approved"
                        }).timeout(Duration(seconds: 30), onTimeout: () {
                          progressDialog.dismiss();
                          DangerAlertBox(
                              context: context,
                              messageText:
                              "Action took so long. Please check your internet connection and try again.",
                              title: "Error");
                          return null;
                        });
                        progressDialog.dismiss();
                        if (response == null) {
                          DangerAlertBox(
                              context: context,
                              messageText:
                              "Unknown error occurred. Please check your internet connection and try again.",
                              title: "Error");
                        } else {
                          final decoded = jsonDecode(response.body) as Map;
                          if (decoded.containsKey("success")) {
                            var status = decoded['success'];
                            if (!status) {
                              DangerAlertBox(
                                  context: context,
                                  messageText: decoded['message'],
                                  title: "Failed");
                              return;
                            } else {
                              SuccessAlertBox(
                                  context: context,
                                  messageText:
                                  "Incident has been approved. Changes will be visible after the next reload",
                                  title: "Success");
                            }
                          }
                        }
                      },
                      title: "Submit");
                },
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SingleImageScreen extends StatelessWidget {
  final imageUrl, tag;

  const SingleImageScreen({Key key, @required this.imageUrl, this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Hero(
            tag: tag,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  Center(child: Icon(Icons.error)),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
