class Product {
  String? productId;
  String? title;
  String? image;
  int? quantity;
  double? price;

  Product({
    this.productId,
    this.title,
    this.image,
    this.quantity,
    this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json['productID'] as String?,
        title: json['title'] as String?,
        image: json['image'] as String?,
        quantity: json['quantity'] as int?,
        price: (json['price'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productID': productId,
        'title': title,
        'image': image,
        'quantity': quantity,
        'price': price,
      };
}
