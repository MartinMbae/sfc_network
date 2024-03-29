
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/map_incident_page.dart';
import 'package:flutter_network/mark_as_resolved_page.dart';
import 'package:flutter_network/models/engineer_incident.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TechnicianAssignedIncidentHolder extends StatefulWidget {
  final EngineerIncident engineerIncident;

  const TechnicianAssignedIncidentHolder(
      {Key key, @required this.engineerIncident})
      : super(key: key);

  @override
  _TechnicianAssignedIncidentHolderState createState() => _TechnicianAssignedIncidentHolderState();
}

class _TechnicianAssignedIncidentHolderState extends State<TechnicianAssignedIncidentHolder> {


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
                      title: "Status",
                      subtitle: widget.engineerIncident.status,
                      subtitleColor:
                          widget.engineerIncident.status == "Approved"
                              ? Colors.green
                              : widget.engineerIncident.status == "Pending"
                                  ? Colors.black
                                  : Colors.red,
                    ),

                    GestureDetector(
                      child: Text("View incident location on map", style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MapIncidentPage() ));
                      },
                    ),

                    RaisedButton(
                      color: Colors.green[600],
                      onPressed: () => cardKey.currentState.toggleCard(),
                      child: Text(
                        'Action',
                        style: TextStyle(color: Colors.white),
                      ),
                    )

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
          height: 180,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mark the Incident as Resolved?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20,),
              Text(
                '(Note. You will need to take a photo to proof your claim.)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 10
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
                    color: Colors.green[600],
                    onPressed: () async{
                      _settingModalBottomSheet(context);
                    },
                    child: Text(
                      'Mark As Resolved',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _settingModalBottomSheet(context){
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MarkAsResolved(
        incidentId:  widget.engineerIncident.incident_id,
        assignmentId:  widget.engineerIncident.assignment_id,
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
