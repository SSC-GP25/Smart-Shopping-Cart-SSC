import 'product_id.dart';

class CartProductModel {
  CartProductModel({
    ProductId? productID,
    int? quantity,
    String? id,
  }) {
    _productID = productID;
    _quantity = quantity;
    _id = id;
  }

  CartProductModel.fromJson(dynamic json) {
    _productID = json['productID'] != null
        ? ProductId.fromJson(json['productID'])
        : null;
    _quantity = json['quantity'];
    _id = json['_id'];
  }
  ProductId? _productID;
  int? _quantity;
  String? _id;

  ProductId? get productID => _productID;
  int? get quantity => _quantity;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_productID != null) {
      map['productID'] = _productID?.toJson();
    }
    map['quantity'] = _quantity;
    map['_id'] = _id;
    return map;
  }
}
