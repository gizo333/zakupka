class Validation {
  static bool isValidEmail(String email) {
    // Проверка формата адреса электронной почты с использованием регулярного выражения
    final String emailRegex =
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z\d-]+(\.[a-zA-Z\d-]+)*\.[a-zA-Z\d-]{2,4}$';
    final RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }
}
