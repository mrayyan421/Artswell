
class kPriceCalculator {
  kPriceCalculator._();
  static double locationTaxRate(String location) {
    return 0.35;
  }
  static int getShippingCost(String location) {
    return 200;
  }
  static double totalCost(double itemPrice, String location, bool mobileApp) {
    double taxRate = locationTaxRate(location);
    double taxCost = itemPrice * taxRate;
    int shippingCost = getShippingCost(location);
    double totalPrice = itemPrice + taxCost + shippingCost;

    return totalPrice;
  }
}
