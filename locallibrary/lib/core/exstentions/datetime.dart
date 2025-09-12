import 'package:intl/intl.dart';

extension ShowDataInOwnFormat on DateTime {
  String showDateInOwnFormat() {
    return DateFormat("EEE, MMM d, y").format(this);
  }
}
