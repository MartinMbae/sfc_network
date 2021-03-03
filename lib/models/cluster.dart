import 'package:flutter/foundation.dart';

class Cluster {
  final id, region_id, cluster_name, created_on, created_by, updated_on,
      updated_by;

  Cluster({
    @required this.id,
    @required this.region_id,
    @required this.cluster_name,
    @required this.created_on,
    @required this.created_by,
    @required this.updated_on,
    @required this.updated_by
  });


  static Cluster fromJson(dynamic json) {
    return Cluster(
        id: json['id'],
        region_id: json['region_name'],
        cluster_name: json['cluster_name'],
        created_on: json['created_on'],
        created_by: json['created_by'],
        updated_on: json['updated_on'],
        updated_by: json['updated_by']
    );
  }

}