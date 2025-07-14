import 'products.dart';

class TransactionModel {
  TransactionModel({
    List<Products>? products,
    String? stripeSessionId,
    int? totalAmount,
    String? paymentMethod,
    String? visa,
  }) {
    _products = products;
    _stripeSessionId = stripeSessionId;
    _totalAmount = totalAmount;
    _paymentMethod = paymentMethod;
    _visa = visa;
  }

  TransactionModel.fromJson(dynamic json) {
    if (json['products'] != null) {
      _products = [];
      json['products'].forEach((v) {
        _products?.add(Products.fromJson(v));
      });
    }
    _stripeSessionId = json['stripeSessionId'];
    _totalAmount = json['totalAmount'];
    _paymentMethod = json['paymentMethod'];
    _visa = json['visa'];
  }

  List<Products>? _products;
  String? _stripeSessionId;
  int? _totalAmount;
  String? _paymentMethod;
  String? _visa;

  List<Products>? get products => _products;

  String? get stripeSessionId => _stripeSessionId;

  int? get totalAmount => _totalAmount;

  String? get paymentMethod => _paymentMethod;

  String? get visa => _visa;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_products != null) {
      map['products'] = _products?.map((v) => v.toJson()).toList();
    }
    map['stripeSessionId'] = _stripeSessionId;
    map['totalAmount'] = _totalAmount;
    map['paymentMethod'] = _paymentMethod;
    map['visa'] = _visa;
    return map;
  }
}
