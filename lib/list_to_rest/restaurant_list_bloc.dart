import 'package:flutter/foundation.dart';

class RestaurantListProvider extends ChangeNotifier {
  Map<String, String> joinRequests = {};

  String getRequestStatus(String restaurantName) {
    return joinRequests[restaurantName] ?? '';
  }
}
