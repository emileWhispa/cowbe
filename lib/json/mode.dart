
class Mode {
  String id;
  String name;

  Mode(this.id, this.name);

  Mode.fromJson(Map<String, dynamic> json)
      : id = json['method_id'],
        name = json['method_name'];

  Map<String, dynamic> toJson() =>
      {'method_id': id, 'method_name': name};
}
