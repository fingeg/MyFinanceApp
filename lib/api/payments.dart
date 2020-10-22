import 'package:flutter_event_bus/flutter_event_bus/EventBus.dart';
import 'package:myfinance_app/api/authentication.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/network.dart';

class PaymentHandler {
  Future<ApiResponse> addPayment(Payment payment, String categoryKey, EventBus eventBus) async {
    final auth = await AuthenticationHandler.getAuthentication();
    final res = await request<int>(
      '/payment',
      HttpMethod.POST,
      key: Keys.payments,
      eventBus: eventBus,
      authentication: auth,
      data: payment.toEncryptedMap(categoryKey),
      jsonParser: (json) => json['id'],
    );

    payment.id = res.data;
    return res;
  }
}
