
import 'cell.dart';

class Village {
  String id;
  String name;
  Cell? cell;

  Village(this.id, this.name);

  Village.fromJson(Map<String, dynamic> json, this.cell)
      : id = json['village_id'],
        name = json['village_name'];

  Map<String, dynamic> toJson() => {'village_id': id, 'village_name': name};
}
