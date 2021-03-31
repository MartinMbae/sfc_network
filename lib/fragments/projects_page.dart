import 'package:flutter/material.dart';
import 'package:flutter_network/fragments/patrol_fragment.dart';
import 'package:flutter_network/fragments/project_fragment.dart';
import 'package:flutter_network/fragments/project_lists_fragment.dart';
import 'package:flutter_network/fragments/technician_patrol_page.dart';



class ProjectSelection extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.add, color: Colors.green,),
            title: Text("Add a Project"),
            onTap: ()async{
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ProjectPage()));
            },
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(Icons.remove_red_eye, color: Colors.green,),
            title: Text("View available projects"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ProjectListPage()));
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
