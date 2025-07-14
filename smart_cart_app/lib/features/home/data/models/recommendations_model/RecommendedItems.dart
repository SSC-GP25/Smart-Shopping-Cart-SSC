class RecommendedItems {
  RecommendedItems({
    String? id,
    String? itemId,
    String? title,
    String? category,
    double? price,
    int? sales,
    int? inventory,
    double? rating,
    String? barcode,
    double? weight,
    String? description,
    String? image,
    List<String>? tags,
    bool? isAvailable,
    int? discount,
    String? aisle,
    List<String>? broughtBy,
    String? section,
    String? createdAt,
    String? updatedAt,
    int? v,
    int? x,
    int? y,
  }) {
    _id = id;
    _itemId = itemId;
    _title = title;
    _category = category;
    _price = price;
    _sales = sales;
    _inventory = inventory;
    _rating = rating;
    _barcode = barcode;
    _weight = weight;
    _description = description;
    _image = image;
    _tags = tags;
    _isAvailable = isAvailable;
    _discount = discount;
    _aisle = aisle;
    _broughtBy = broughtBy;
    _section = section;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
    _x = x;
    _y = y;
  }

  RecommendedItems.fromJson(dynamic json) {
    _id = json['_id'];
    _itemId = json['item_id'];
    _title = json['title'];
    _category = json['category'];
    _price = json['price'] is int
        ? (json['price'] as int).toDouble()
        : json['price'];
    _sales = json['sales'];
    _inventory = json['inventory'];
    _rating = json['rating'] is int
        ? (json['rating'] as int).toDouble()
        : json['rating'];
    _barcode = json['barcode'];
    _weight = json['weight'] is int
        ? (json['weight'] as int).toDouble()
        : json['weight'];
    _description = json['description'];
    _image = json['image'];
    if (json['tags'] != null) {
      _tags = [];
      json['tags'].forEach((v) {
        _tags?.add(v);
      });
    }
    _isAvailable = json['isAvailable'];
    _discount = json['discount'];
    _aisle = json['aisle'];
    if (json['broughtBy'] != null) {
      _broughtBy = [];
      json['broughtBy'].forEach((v) {
        _broughtBy?.add(v);
      });
    }
    _section = json['section'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
    _x = json['x'];
    _y = json['y'];
  }

  String? _id;
  String? _itemId;
  String? _title;
  String? _category;
  double? _price;
  int? _sales;
  int? _inventory;
  double? _rating;
  String? _barcode;
  double? _weight;
  String? _description;
  String? _image;
  List<dynamic>? _tags;
  bool? _isAvailable;
  int? _discount;
  String? _aisle;
  List<dynamic>? _broughtBy;
  String? _section;
  String? _createdAt;
  String? _updatedAt;
  int? _v;
  int? _x;
  int? _y;

  int? get x => _x;

  int? get y => _y;


  String? get id => _id;

  String? get itemId => _itemId;

  String? get title => _title;

  String? get category => _category;

  double? get price => _price;

  int? get sales => _sales;

  int? get inventory => _inventory;

  double? get rating => _rating;

  String? get barcode => _barcode;

  double? get weight => _weight;

  String? get description => _description;

  String? get image => _image;

  List<dynamic>? get tags => _tags;

  bool? get isAvailable => _isAvailable;

  int? get discount => _discount;

  String? get aisle => _aisle;

  List<dynamic>? get broughtBy => _broughtBy;

  String? get section => _section;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  int? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['item_id'] = _itemId;
    map['title'] = _title;
    map['category'] = _category;
    map['price'] = _price;
    map['sales'] = _sales;
    map['inventory'] = _inventory;
    map['rating'] = _rating;
    map['barcode'] = _barcode;
    map['weight'] = _weight;
    map['description'] = _description;
    map['image'] = _image;
    if (_tags != null) {
      map['tags'] = _tags?.map((v) => v.toJson()).toList();
    }
    map['isAvailable'] = _isAvailable;
    map['discount'] = _discount;
    map['aisle'] = _aisle;
    if (_broughtBy != null) {
      map['broughtBy'] = _broughtBy?.map((v) => v.toJson()).toList();
    }
    map['section'] = _section;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    map['x'] = _x;
    map['y'] = _y;
    return map;
  }
}
