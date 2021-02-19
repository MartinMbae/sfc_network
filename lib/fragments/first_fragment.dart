import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_network/fragments/line_fragment.dart';
import 'package:flutter_network/utils/shared_pref.dart';
import 'package:pie_chart/pie_chart.dart';


class FirstFragment extends StatefulWidget {

  @override
  _FirstFragmentState createState() => _FirstFragmentState();
}

class _FirstFragmentState extends State<FirstFragment> {
  String roleName = "n";
  String roleArticle;
  Future<bool> fetchUserRole() async{
    SessionManager prefs = SessionManager();
    String roleString =await prefs.getRole();
    int role = int.parse(roleString);
    if (role == 2){
      setState(() {
        roleName = "Engineer";
        roleArticle = "an";
      });
    }else{
      setState(() {
        roleName = "Technician";
        roleArticle = "a";
      });
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Map<String, double> dataMap = {
      "Resolved": 5,
      "Unresolved": 3,
    };

    return SingleChildScrollView(
      child: Column(
        children:[
          SizedBox(
            height: 15,
          ),
          FutureBuilder(
            future: fetchUserRole(),
            builder: (context, snapshot){
              if (snapshot.hasData){
                return RichText(text:
                TextSpan(
                    children: [
                      TextSpan(
                          text: "You are logged in as",
                      ),
                      TextSpan(
                          text:  " $roleArticle $roleName",
                          style: TextStyle(fontWeight: FontWeight.w500, decoration:TextDecoration.underline)
                      ),
                    ],
                  style: TextStyle(fontSize: 14, color: Colors.black)
                ),

                );
              }else{
                return Container();
              }
            },
          ),
          SizedBox(
            height: 15,
          ),

          PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 1000),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 2,
          initialAngleInDegree: 0,
          chartType: ChartType.disc,
          legendOptions: LegendOptions(
            showLegendsInRow: true,
            legendPosition: LegendPosition.bottom,
            showLegends: true,
            legendShape: BoxShape.rectangle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
          ),
        ),
          Divider(color: Colors.black,),
          GraphBottom(),
        ],
      ),
    );
  }
}