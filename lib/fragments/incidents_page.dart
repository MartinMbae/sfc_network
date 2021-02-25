import 'package:flutter/material.dart';
import 'package:flutter_network/fragments/report_incident.dart';
import 'package:flutter_network/fragments/technician_incidents_fragment.dart';
import 'package:permission_handler/permission_handler.dart';



class Incidents extends StatelessWidget {


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
            leading: Icon(Icons.report, color: Colors.deepPurple,),
            title: Text("Report an incident"),
            onTap: ()async{

            bool hasPermission =  await checkPermissions();
              if (hasPermission){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ReportIncident()));
              }else{
                Scaffold.of(context).showSnackBar(SnackBar(content: Text("Give location permissions"),));
              }
            },
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(Icons.remove_red_eye, color: Colors.deepPurple,),
            title: Text("View Incidents"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> TechnicianIncidentsPage()));
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
