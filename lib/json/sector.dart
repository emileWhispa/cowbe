
import 'district.dart';

class Sector {
  String id;
  String name;
  String? category;
  District? district;

  Sector(this.id, this.name);

  Sector.fromJson(Map<String, dynamic> json, this.district)
      : id = json['sector_id'],
        name = json['sector_name'],
        category = json['sector_category'];

  Map<String, dynamic> toJson() =>
      {'sector_id': id, 'sector_name': name, 'sector_category': category};
}
