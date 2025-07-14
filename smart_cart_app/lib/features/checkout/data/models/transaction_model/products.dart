class Products {
  Products({
    String? productID,
    int? quantity,
  }) {
    _productID = productID;
    _quantity = quantity;
  }

  Products.fromJson(dynamic json) {
    _productID = json['productID'];
    _quantity = json['quantity'];
  }

  String? _productID;
  int? _quantity;

  String? get productID => _productID;

  int? get quantity => _quantity;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['productID'] = _productID;
    map['quantity'] = _quantity;
    return map;
  }
}
