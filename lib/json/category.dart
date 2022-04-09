
class Category {
  String id;
  String name;

  Category(this.id, this.name);

  Category.fromJson(Map<String, dynamic> json)
      : id = json['category_id'],
        name = json['category_name'];

  Map<String, dynamic> toJson() => {'category_id': id, 'category_name': name};
}
