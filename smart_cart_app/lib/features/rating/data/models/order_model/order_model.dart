import 'product.dart';

class OrderModel {
  String? orderId;
  int? totalPrice;
  List<Product>? products;

  OrderModel({this.orderId, this.totalPrice, this.products});

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        orderId: json['orderID'] as String?,
        totalPrice: json['totalPrice'] as int?,
        products: (json['products'] as List<dynamic>?)
            ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'orderID': orderId,
        'totalPrice': totalPrice,
        'products': products?.map((e) => e.toJson()).toList(),
      };
}
