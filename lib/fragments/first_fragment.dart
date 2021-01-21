import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class FirstFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    Map<String, double> dataMap = {
      "Resolved": 5,
      "Unresolved": 3,
    };

    return Center(
      child: PieChart(
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
    );
  }
}