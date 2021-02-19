import 'package:flutter/material.dart';


Future<void> goToNextPageRemoveHistory(BuildContext context,  Widget newRoute) async {
  return await Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => newRoute), (route) => false);
}

Future navigateToPage(context, page) async {
  await Navigator.push(
      context, MaterialPageRoute(builder: (context) => page));
}