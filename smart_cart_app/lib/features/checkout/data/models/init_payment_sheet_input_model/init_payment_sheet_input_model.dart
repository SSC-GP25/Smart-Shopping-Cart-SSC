class InitPaymentSheetInputModel {
  final String paymentIntentClientSecret,
      customerEphemeralKeySecret,
      customerID;

  InitPaymentSheetInputModel({
    required this.paymentIntentClientSecret,
    required this.customerEphemeralKeySecret,
    required this.customerID,
  });
}
