
import 'sector.dart';

class Cell {
  String? id;
  String? name;
  Sector? sector;

  Cell(this.id, this.name);

  Cell.fromJson(Map<String, dynamic> json, this.sector)
      : id = json['cell_id'],
        name = json['cell_name'];
  Map<String, dynamic> toJson() => {'cell_id': id, 'cell_name': name};
}
