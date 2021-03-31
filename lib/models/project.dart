import 'package:flutter/foundation.dart';

class Project {


  final project_id, tech_name, site_name, site_type, description, created_by;

  Project({
    @required this.project_id,
    @required this.tech_name,
    @required this.site_name,
    @required this.site_type,
    @required this.description,
    @required this.created_by,
  });


  static Project fromJson(dynamic json) {
    return Project(
        project_id: json['project_id'],
        tech_name: json['tech_name'],
        site_name: json['site_name'],
        site_type: json['site_type'],
      description: json['description'],
        created_by: json['created_by'],
    );
  }

}