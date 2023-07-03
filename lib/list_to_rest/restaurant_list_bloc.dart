import 'package:flutter/foundation.dart';

class RestaurantListProvider extends ChangeNotifier {
  String? selectedRestaurant;
  Map<String, Map<String, String>> joinRequests = {};

  String getRequestStatus(String restaurantName, String userId) {
    final userRequests = joinRequests[restaurantName];
    if (userRequests != null) {
      return userRequests[userId] ?? '';
    }
    return '';
  }
}