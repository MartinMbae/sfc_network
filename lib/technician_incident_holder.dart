import 'dart:convert';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/models/engineer_incident.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_network/utils/constants.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class TechnicianIncidentHolder extends StatefulWidget {
  final EngineerIncident engineerIncident;
  final int num;

  const TechnicianIncidentHolder(
      {Key key, @required this.engineerIncident, @required this.num})
      : super(key: key);

  @override
  _TechnicianIncidentHolderState createState() => _TechnicianIncidentHolderState();
}

class _TechnicianIncidentHolderState extends State<TechnicianIncidentHolder> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  ArsProgressDialog progressDialog;

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
        height: 140,
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
                      title: "Status",
                      subtitle: widget.engineerIncident.status,
                      subtitleColor:
                          widget.engineerIncident.status == "Approved"
                              ? Colors.green
                              : widget.engineerIncident.status == "Pending"
                                  ? Colors.black
                                  : Colors.red,
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
          height: 140,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Take Action on this incident',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    color: Colors.red[600],
                    onPressed: () async {
                      cardKey.currentState.toggleCard();
                      var reason = await prompt(
                        context,
                        title: Text(
                            'Are you sure you would like to reject this incident'),
                        textOK: Text('Yes'),
                        textCancel: Text('No'),
                        hintText: 'Please write reason',
                        minLines: 1,
                        maxLines: 3,
                      );
                      if (reason == null){
                        return;
                      }
                      progressDialog.show();
                      SessionManager prefs = new SessionManager();
                      String userId = await prefs.getId();
                      var url =
                          "${BASE_URL}v1/api/incidentAction/${widget.engineerIncident.incident_id}";
                      http.Response response = await http.put(url, body: {
                        'engineer_id': "$userId",
                        'status': "Rejected",
                        'reason': reason,
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
                                    "Incident has been rejected. Changes will be visible after the next reload",
                                title: "Success");
                          }
                        }
                      }
                    },
                    child: Text(
                      'Reject',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    color: Colors.green[600],
                    onPressed: () {
                      cardKey.currentState.toggleCard();
                      ConfirmAlertBox(
                          context: context,
                          infoMessage:
                              "Are you sure you want to approve this incident?",
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
                          title: "Confirm");
                    },
                    child: Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
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
