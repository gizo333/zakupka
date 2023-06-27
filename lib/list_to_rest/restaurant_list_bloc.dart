import 'package:flutter/foundation.dart';

class RestaurantListProvider extends ChangeNotifier {
  String? selectedRestaurant;
  Map<String, String> joinRequests = {};

  String getRequestStatus(String restaurantName) {
    return joinRequests[restaurantName] ?? '';
  }
}