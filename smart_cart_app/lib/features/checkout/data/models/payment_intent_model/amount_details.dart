class AmountDetails {
  AmountDetails({
    dynamic tip,
  }) {
    _tip = tip;
  }

  AmountDetails.fromJson(dynamic json) {
    _tip = json['tip'];
  }
  dynamic _tip;

  dynamic get tip => _tip;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['tip'] = _tip;
    return map;
  }
}
