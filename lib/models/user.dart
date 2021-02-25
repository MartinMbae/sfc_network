import 'package:flutter/material.dart';

class User{
  //{"success":true,"message":"Login successful","id":"1","first_name":"System","last_name":"Admin","email":"glob.admin","phone":"0987654567","created_at":"2019-03-01 09:31:01"}

  final String id;
  final String firstName, lastName, username, email, phone, role, createdAt;

  User({
    @required this.id, @required this.firstName, @required this.role, @required this.lastName, @required this.username, @required this.email, @required this.phone, this.createdAt
  });

}