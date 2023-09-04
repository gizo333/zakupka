import 'package:flutter/foundation.dart';

import '../connect_BD/connect_web.dart';

class RestaurantListProvider extends ChangeNotifier {
  String? selectedRestaurant;
  Map<String, Map<String, String>> joinRequests = {};
  String? currentJoinRequestRestaurant;

  // удаления запроса для поставщика
  Future<void> cancelJoinRequest(String restaurantName, String userId,
      RestaurantListProvider restaurantListProvider) async {
    print('Cancelling join request for User ID: $userId');

    final response = await companyConnect('comp_join_requests', '', body: {
      "restaurant_name": restaurantName,
      "user_id": userId,
      "operation": "delete"
    });

    if (response.containsKey('error')) {
      // Обработка ошибки при удалении записи
      print('Error canceling join request: ${response['error']}');
      throw Exception('Error canceling join request');
    } else {
      // Успешное удаление записи
      print('Join request canceled successfully');
      // Дополнительные действия после успешного удаления записи
    }
    if (restaurantListProvider.currentJoinRequestRestaurant == restaurantName) {
      restaurantListProvider.currentJoinRequestRestaurant = null;
    }
    restaurantListProvider.joinRequests[restaurantName]?.remove(userId);
    restaurantListProvider.notifyListeners();
    print('Join request cancelled successfully for User ID2312321: $userId');
  }

  Future<void> cancelSotrudJoinRequest(String restaurantName, String userId,
      RestaurantListProvider restaurantListProvider) async {
    print('Cancelling join request for User ID: $userId');

    final response = await sotrudConnect('join_requests', '', body: {
      "restaurant_name": restaurantName,
      "user_id": userId,
      "operation": "delete"
    });

    if (response.containsKey('error')) {
      // Обработка ошибки при удалении записи
      print('Error canceling join request: ${response['error']}');
      throw Exception('Error canceling join request');
    } else {
      // Успешное удаление записи
      print('Join request canceled successfully');
      // Дополнительные действия после успешного удаления записи
    }
    if (restaurantListProvider.currentJoinRequestRestaurant == restaurantName) {
      restaurantListProvider.currentJoinRequestRestaurant = null;
    }
    restaurantListProvider.joinRequests[restaurantName]?.remove(userId);
    restaurantListProvider.notifyListeners();
    print('Join request cancelled successfully for User ID2312321: $userId');
  }

  String getRequestStatus(String restaurantName, String userId) {
    final userRequests = joinRequests[restaurantName];
    if (userRequests != null) {
      return userRequests[userId] ?? '';
    }
    return '';
  }
}
