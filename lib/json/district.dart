
class District {
  String id;
  String name;

  District(this.id, this.name);

  District.fromJson(Map<String, dynamic> json)
      : id = json['district_id'],
        name = json['district_name'];

  Map<String, dynamic> toJson() => {'district_id': id, 'district_name': name};
}
