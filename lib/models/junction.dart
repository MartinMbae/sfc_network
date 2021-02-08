

import 'package:equatable/equatable.dart';

class Junction extends Equatable{

  final id, cluster_id, component_name,comp_type,category,subcategory,technique,function,dimension,description,alocation,
  alocationdesc,zlocation,zlocationdesc,effectivelength,geolength,owner,status,status_date,routing,location_type,
  usedby,created_on,created_by,updated_on,updated_by;

  Junction({this.id, this.cluster_id, this.component_name, this.comp_type, this.category, this.subcategory, this.technique, this.function, this.dimension, this.description, this.alocation, this.alocationdesc, this.zlocation, this.zlocationdesc, this.effectivelength, this.geolength, this.owner, this.status, this.status_date, this.routing, this.location_type, this.usedby, this.created_on, this.created_by, this.updated_on, this.updated_by});

  @override
  List<Object> get props => throw UnimplementedError();

  static Junction fromJson(dynamic json) {
    return Junction(
      id: json['id'],
      cluster_id: json['cluster_id'],
      component_name: json['component_name'],
      comp_type: json['comp_type'],
      category: json['category'],
      subcategory: json['subcategory'],
      technique: json['technique'],
      function: json['function'],
      dimension: json['dimension'],
      description: json['description'],
      alocation: json['alocation'],
      alocationdesc: json['alocationdesc'],
      zlocation: json['zlocation'],
      zlocationdesc: json['zlocationdesc'],
      effectivelength: json['effectivelength'],
      geolength: json['geolength'],
      owner: json['owner'],
      status: json['status'],
      status_date: json['status_date'],
      routing: json['routing'],
      location_type: json['locationtype'],
      usedby: json['usedby'],
      created_on: json['created_on'],
      created_by: json['created_by'],
      updated_on: json['updated_on'],
      updated_by: json['updated_by'],

    );
  }

  @override
  String toString() => 'Junction{ id: $id }';


}