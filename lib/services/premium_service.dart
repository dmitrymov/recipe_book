class PremiumService {
  bool _paid = false;

  bool get isPaid => _paid;

  void purchase() {
    // In a real app, integrate in_app_purchase or a custom gateway.
    _paid = true;
  }
}
