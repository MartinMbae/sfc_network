class EngineerIncident {
  final success,
      incident_id,
      tech_id,
      incident_type,
      crq_no,
      manhole_name,
      incident_desc,
      reported_on,
      incident_image,
      status,
      created_at;

  EngineerIncident(
      {this.success,
      this.incident_id,
      this.tech_id,
      this.incident_type,
      this.crq_no,
      this.manhole_name,
      this.incident_desc,
      this.reported_on,
      this.status,
      this.incident_image,
      this.created_at});

  static EngineerIncident fromJson(dynamic json) {
    return EngineerIncident(
      success: json['success'],
      incident_id: json['incident_id'],
      tech_id: json['tech_id'],
      incident_type: json['incident_type'],
      crq_no: json['crq_no'],
      manhole_name: json['manhole_name'],
      incident_desc: json['incident_desc'],
      reported_on: json['reported_on'],
      status: json['status'],
      incident_image: json['incident_image'],
      created_at: json['created_at'],
    );
  }
}
