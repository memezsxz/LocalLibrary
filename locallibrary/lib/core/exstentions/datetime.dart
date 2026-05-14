import 'package:intl/intl.dart';

extension ShowDataInOwnFormat on DateTime {
  String showDateInOwnFormat() {
    return DateFormat("MMM d, y").format(this);
  }
}
