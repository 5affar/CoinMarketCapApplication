class HelperFunctions {
  static String formatLargeNumber(double num) {
    if (num >= 1e12) {
      return '${(num / 1e12).toStringAsFixed(2)} T'; // Trillions
    } else if (num >= 1e9) {
      return '${(num / 1e9).toStringAsFixed(2)} B'; // Billions
    } else if (num >= 1e6) {
      return '${(num / 1e6).toStringAsFixed(2)} M'; // Millions
    } else {
      return num.toStringAsFixed(2); // Smaller numbers
    }
  }
}
