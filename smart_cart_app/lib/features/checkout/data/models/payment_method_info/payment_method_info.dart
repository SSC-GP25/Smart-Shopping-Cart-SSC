import 'payment_card.dart';

class PaymentMethodInfo {
  String? id;
  String? object;
  PaymentCard? card;
  int? created;
  String? customer;
  bool? livemode;
  String? type;

  PaymentMethodInfo({
    this.id,
    this.object,
    this.card,
    this.created,
    this.customer,
    this.livemode,
    this.type,
  });

  factory PaymentMethodInfo.fromJson(Map<String, dynamic> json) {
    return PaymentMethodInfo(
      id: json['id'] as String?,
      object: json['object'] as String?,
      card: json['card'] == null
          ? null
          : PaymentCard.fromJson(json['card'] as Map<String, dynamic>),
      created: json['created'] as int?,
      customer: json['customer'] as String?,
      livemode: json['livemode'] as bool?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'object': object,
        'card': card?.toJson(),
        'created': created,
        'customer': customer,
        'livemode': livemode,
        'type': type,
      };
}
