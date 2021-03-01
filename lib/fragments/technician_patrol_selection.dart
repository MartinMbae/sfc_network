import 'package:flutter/material.dart';
import 'package:flutter_network/fragments/patrol_fragment.dart';
import 'package:flutter_network/fragments/report_incident.dart';
import 'package:flutter_network/fragments/technician_incidents_fragment.dart';
import 'package:flutter_network/fragments/technician_patrol_page.dart';
import 'package:permission_handler/permission_handler.dart';



class TechnicianPatrolSelection extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.report, color: Colors.green,),
            title: Text("Perform Patrol"),
            onTap: ()async{
              Navigator.push(context, MaterialPageRoute(builder: (context)=> PatrolPage()));
            },
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(Icons.remove_red_eye, color: Colors.green,),
            title: Text("Review My previous Patrols"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> TechnicianPatrolPage()));
            },
          ),
          Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
