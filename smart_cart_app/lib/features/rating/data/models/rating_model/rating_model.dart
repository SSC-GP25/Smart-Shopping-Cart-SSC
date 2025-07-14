class RatingModel {
  RatingModel({
    String? productID,
    int? userRating,
  }) {
    _productID = productID;
    _userRating = userRating;
  }

  RatingModel.fromJson(dynamic json) {
    _productID = json['productID'];
    _userRating = json['userRating'];
  }

  String? _productID;
  int? _userRating;

  String? get productID => _productID;

  int? get userRating => _userRating;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['productID'] = _productID;
    map['userRating'] = _userRating;
    return map;
  }
}
