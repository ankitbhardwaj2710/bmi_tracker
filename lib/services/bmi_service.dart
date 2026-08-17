class BmiService {
  static double calculate({
    required double weight,
    required String weightUnit,
    required double height,
    required String heightUnit,
  }) {
    double weightKg = weight;
    double heightMeters;

    // Convert pounds to kilograms
    if (weightUnit == 'LBS') {
      weightKg = weight * 0.45359237;
    }

    // Convert height to meters
    if (heightUnit == 'CM') {
      heightMeters = height / 100;
    } else {
      // Inches to meters
      heightMeters = height * 0.0254;
    }

    if (heightMeters <= 0 || weightKg <= 0) {
      throw ArgumentError('Weight and height must be greater than zero');
    }

    return weightKg / (heightMeters * heightMeters);
  }

  static String getCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal weight';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }
}