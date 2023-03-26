class AssetModel {
  AssetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;
  String name;
  String type;
  String image;
  DateTime createdAt;
  DateTime updatedAt;

  factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        image: json["image"],
        createdAt: DateTime.parse(json["created_at"]).toLocal(),
        updatedAt: DateTime.parse(json["updated_at"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "image": image,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
