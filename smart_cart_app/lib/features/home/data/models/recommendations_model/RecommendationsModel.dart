import 'RecommendedItems.dart';

class RecommendationsModel {
  RecommendationsModel({
    String? status,
    int? results,
    List<RecommendedItems>? recommendedItems,
    String? message,
  }) {
    _status = status;
    _results = results;
    _recommendedItems = recommendedItems;
    _message = message;
  }

  RecommendationsModel.fromJson(dynamic json) {
    _status = json['status'];
    _results = json['results'];
    if (json['recommendedItems'] != null) {
      _recommendedItems = [];
      json['recommendedItems'].forEach((v) {
        _recommendedItems?.add(RecommendedItems.fromJson(v));
      });
    }
    _message = json['message'];
  }

  String? _status;
  int? _results;
  List<RecommendedItems>? _recommendedItems;
  String? _message;

  String? get status => _status;

  int? get results => _results;

  List<RecommendedItems>? get recommendedItems => _recommendedItems;

  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['results'] = _results;
    if (_recommendedItems != null) {
      map['recommendedItems'] =
          _recommendedItems?.map((v) => v.toJson()).toList();
    }
    map['message'] = _message;
    return map;
  }
}
