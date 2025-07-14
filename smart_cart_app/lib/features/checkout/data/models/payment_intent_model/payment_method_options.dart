import 'Card.dart';
import 'Link.dart';

class PaymentMethodOptions {
  PaymentMethodOptions({
    Card? card,
    Link? link,
  }) {
    _card = card;
    _link = link;
  }

  PaymentMethodOptions.fromJson(dynamic json) {
    _card = json['card'] != null ? Card.fromJson(json['card']) : null;
    _link = json['link'] != null ? Link.fromJson(json['link']) : null;
  }
  Card? _card;
  Link? _link;

  Card? get card => _card;
  Link? get link => _link;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_card != null) {
      map['card'] = _card?.toJson();
    }
    if (_link != null) {
      map['link'] = _link?.toJson();
    }
    return map;
  }
}
