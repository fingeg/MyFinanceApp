import 'package:flutter_event_bus/flutter_event_bus/EventBus.dart';
import 'package:myfinance_app/api/authentication.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/network.dart';

class PaymentHandler {
  /// Adds or updates a payment
  Future<ApiResponse> setPayment(
      Payment payment, String categoryKey, EventBus eventBus) async {
    final auth = await AuthenticationHandler.getAuthentication();
    final res = await request<int>(
      '/payment',
      HttpMethod.POST,
      key: Keys.payments,
      eventBus: eventBus,
      authentication: auth,
      data: payment.toEncryptedJson(categoryKey),
      jsonParser: (json) => json['id'],
    );

    payment.id = res.data;
    return res;
  }

  /// Deletes a payment
  Future<ApiResponse<bool>> deletePayment(Payment payment) async {
    final auth = await AuthenticationHandler.getAuthentication();
    return request<bool>(
      '/payment',
      HttpMethod.DELETE,
      authentication: auth,
      data: {'id': payment.id},
      jsonParser: (json) => json['status'],
    );
  }
}
