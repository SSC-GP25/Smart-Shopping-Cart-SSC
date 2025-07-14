class MapSearchProductModel {
  String? id;
  String? itemId;
  String? title;
  String? category;
  double? price;
  int? sales;
  int? inventory;
  double? rating;
  String? barcode;
  double? weight;
  String? description;
  String? image;
  List<dynamic>? tags;
  bool? isAvailable;
  int? discount;
  String? aisle;
  List<dynamic>? broughtBy;
  String? section;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? x;
  int? y;

  MapSearchProductModel({
    this.id,
    this.itemId,
    this.title,
    this.category,
    this.price,
    this.sales,
    this.inventory,
    this.rating,
    this.barcode,
    this.weight,
    this.description,
    this.image,
    this.tags,
    this.isAvailable,
    this.discount,
    this.aisle,
    this.broughtBy,
    this.section,
    this.createdAt,
    this.updatedAt,
    this.x,
    this.y,
  });

  factory MapSearchProductModel.fromJson(Map<String, dynamic> json) {
    return MapSearchProductModel(
      id: json['_id'] as String?,
      itemId: json['item_id'] as String?,
      title: json['title'] as String?,
      category: json['category'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      sales: json['sales'] as int?,
      inventory: json['inventory'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      barcode: json['barcode'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      description: json['description'] as String?,
      image: json['image'] as String?,
      tags: json['tags'] as List<dynamic>?,
      isAvailable: json['isAvailable'] as bool?,
      discount: json['discount'] as int?,
      aisle: json['aisle'] as String?,
      broughtBy: json['broughtBy'] as List<dynamic>?,
      section: json['section'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      x: json['x'] as int?,
      y: json['y'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'item_id': itemId,
        'title': title,
        'category': category,
        'price': price,
        'sales': sales,
        'inventory': inventory,
        'rating': rating,
        'barcode': barcode,
        'weight': weight,
        'description': description,
        'image': image,
        'tags': tags,
        'isAvailable': isAvailable,
        'discount': discount,
        'aisle': aisle,
        'broughtBy': broughtBy,
        'section': section,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'x': x,
        'y': y,
      };
}
