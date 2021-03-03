import 'package:flutter/material.dart';
import 'package:flutter_network/fragments/patrol_fragment.dart';
import 'package:flutter_network/fragments/report_incident.dart';
import 'package:flutter_network/fragments/technician_incidents_page.dart';
import 'package:flutter_network/fragments/technician_patrol_page.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';



class TechnicianPatrolSelection extends StatelessWidget {



  Future<bool> checkPermissions() async {
    var status = await Permission.location.status;
    if (status.isUndetermined ||
        status.isDenied ||
        status.isPermanentlyDenied) {
      if (await Permission.location.request().isGranted) {
        return true;
      } else {
        if (status.isPermanentlyDenied){
          openAppSettings();
        }
      }
      return false;
    } else {
      return true;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.report, color: Colors.green,),
            title: Text("Perform Patrol"),
            onTap: ()async{

              bool hasPermission =  await checkPermissions();
              if (hasPermission){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> PatrolPage()));
              }else{
                Scaffold.of(context).showSnackBar(SnackBar(content: Text("Give location permissions"),));
              }
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
