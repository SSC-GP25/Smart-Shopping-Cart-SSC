class PaymentCard {
  String? brand;
  String? country;
  String? displayBrand;
  int? expMonth;
  int? expYear;
  String? fingerprint;
  String? funding;
  dynamic generatedFrom;
  String? last4;
  String? regulatedStatus;
  dynamic wallet;

  PaymentCard({
    this.brand,
    this.country,
    this.displayBrand,
    this.expMonth,
    this.expYear,
    this.fingerprint,
    this.funding,
    this.generatedFrom,
    this.last4,
    this.regulatedStatus,
    this.wallet,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) => PaymentCard(
        brand: json['brand'] as String?,
        country: json['country'] as String?,
        displayBrand: json['display_brand'] as String?,
        expMonth: json['exp_month'] as int?,
        expYear: json['exp_year'] as int?,
        fingerprint: json['fingerprint'] as String?,
        funding: json['funding'] as String?,
        generatedFrom: json['generated_from'] as dynamic,
        last4: json['last4'] as String?,
        regulatedStatus: json['regulated_status'] as String?,
        wallet: json['wallet'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'country': country,
        'display_brand': displayBrand,
        'exp_month': expMonth,
        'exp_year': expYear,
        'fingerprint': fingerprint,
        'funding': funding,
        'generated_from': generatedFrom,
        'last4': last4,
        'regulated_status': regulatedStatus,
        'wallet': wallet,
      };
}
