import 'package:flutter/foundation.dart';

class Site {
  final id,
      msp_id,
      name,
      site_type,
      locationlevel,
      locationsystem,
      regionID,
      latitude,
      longitude,
      room,
      floor,
      street,
      no,
      city,
      zipcode,
      township,
      countyID,
      country,
      status,
      status_date,
      routing,
      locationtype,
      description,
      owner,
      usedby,
      created_on,
      created_by,
      updated_on,
      updated_by;

  Site({
    @required this.id,
    @required this.msp_id,
    @required this.name,
    @required this.site_type,
    @required this.locationlevel,
    @required this.locationsystem,
    @required this.regionID,
    @required this.latitude,
    @required this.longitude,
    @required this.room,
    @required this.floor,
    @required this.street,
    @required this.no,
    @required this.city,
    @required this.zipcode,
    @required this.township,
    @required this.countyID,
    @required this.country,
    @required this.status,
    @required this.status_date,
    @required this.routing,
    @required this.locationtype,
    @required this.description,
    @required this.owner,
    @required this.usedby,
    @required this.created_on,
    @required this.created_by,
    @required this.updated_on,
    @required this.updated_by,
  });

  static Site fromJson(dynamic json) {
    return Site(
      id: json['id'],
      msp_id: json['msp_id'],
      name: json['name'],
      site_type: json['site_type'],
      locationlevel: json['locationlevel'],
      locationsystem: json['locationsystem'],
      regionID: json['regionID'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      room: json['room'],
      floor: json['floor'],
      street: json['street'],
      no: json['no'],
      city: json['city'],
      zipcode: json['zipcode'],
      township: json['township'],
      countyID: json['countyID'],
      country: json['country'],
      status: json['status'],
      status_date: json['status_date'],
      routing: json['routing'],
      locationtype: json['locationtype'],
      description: json['description'],
      owner: json['owner'],
      usedby: json['usedby'],
      created_on: json['created_on'],
      created_by: json['created_by'],
      updated_on: json['updated_on'],
      updated_by: json['updated_by'],
    );
  }
}
