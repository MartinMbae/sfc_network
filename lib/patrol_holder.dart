import 'dart:convert';

import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_network/Widget/simple_row.dart';
import 'package:flutter_network/fragments/patrol_fragment.dart';
import 'package:flutter_network/models/engineer_incident.dart';
import 'package:flutter_network/models/patroll.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_network/utils/constants.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class EngineerPatrolHolder extends StatefulWidget {
  final Patrol patrol;
  final int num;

  const EngineerPatrolHolder(
      {Key key, @required this.patrol, @required this.num})
      : super(key: key);

  @override
  _EngineerPatrolHolderState createState() => _EngineerPatrolHolderState();
}

class _EngineerPatrolHolderState extends State<EngineerPatrolHolder> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  ArsProgressDialog progressDialog;

  @override
  Widget build(BuildContext context) {
    String heroTag = "imageHero${widget.patrol.patrol_id}";

    Size size = MediaQuery.of(context).size;
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));

    return  Container(
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
                        imageUrl: widget.patrol.photo,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            Center(child: Icon(Icons.error, color: Colors.red,)),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return SingleImageScreen(
                            tag: heroTag,
                            imageUrl: widget.patrol.photo);
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
                      title: "Site Type",
                      subtitle: widget.patrol.site_type),
                  SimpleRow(
                      title: "Site name",
                      subtitle: widget.patrol.site_name),
                  SimpleRow(
                      title: "Description",
                      subtitle: widget.patrol.description),

                  SimpleRow(
                    title: "Status",
                    subtitle: widget.patrol.status,
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
