import '../models/user_model.dart';

class CalorieCalculator {
  static int calculateBMR(UserModel user) {
    if (user.weight == null || user.height == null || user.age == null || user.gender == null) {
      return 2000;
    }

    if (user.gender == 'male') {
      return (10 * user.weight! + 6.25 * user.height! - 5 * user.age! + 5).round();
    } else if (user.gender == 'female') {
      return (10 * user.weight! + 6.25 * user.height! - 5 * user.age! - 161).round();
    } else {
      return 2000;
    }
  }

}