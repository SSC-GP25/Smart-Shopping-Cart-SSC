class PostCategoriesModel {
  PostCategoriesModel({
    List<String>? likedCategories,
  }) {
    _likedCategories = likedCategories;
  }

  PostCategoriesModel.fromJson(dynamic json) {
    _likedCategories = json['likedCategories'] != null
        ? json['likedCategories'].cast<String>()
        : [];
  }
  List<String>? _likedCategories;

  List<String>? get likedCategories => _likedCategories;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['likedCategories'] = _likedCategories;
    return map;
  }
}
