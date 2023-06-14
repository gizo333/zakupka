int compareNumeric(bool ascending, int value1, int value2) {
  if (ascending) {
    return value1.compareTo(value2);
  } else {
    return value2.compareTo(value1);
  }
}

int compareString(bool ascending, String value1, String value2) =>
    ascending ? value1.compareTo(value2) : value2.compareTo(value1);