import './data.dart';

class CategoriesModel {
  CategoriesModel({
    String? status,
    int? results,
    Data? data,
  }) {
    _status = status;
    _results = results;
    _data = data;
  }

  CategoriesModel.fromJson(dynamic json) {
    _status = json['status'];
    _results = json['results'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? _status;
  int? _results;
  Data? _data;

  String? get status => _status;
  int? get results => _results;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['results'] = _results;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}
