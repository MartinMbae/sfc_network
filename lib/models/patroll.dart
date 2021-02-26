import 'package:flutter/foundation.dart';

class Patrol {
  final patrol_id,
      tech_name,
      site_name,
      site_type,
      photo,
      description,
      status,
      reported_on;

  Patrol({
    @required this.patrol_id,
    @required this.tech_name,
    @required this.site_type,
    @required this.site_name,
    @required this.photo,
    @required this.description,
    @required this.status,
    @required this.reported_on,
  });

  static Patrol fromJson(dynamic json) {
    return Patrol(
      patrol_id: json['patrol_id'],
      tech_name: json['tech_name'],
      site_type: json['site_type'],
      site_name: json['site_name'],
      photo: json['photo'],
      description: json['description'],
      status: json['status'],
      reported_on: json['reported_on'],
    );
  }
}
