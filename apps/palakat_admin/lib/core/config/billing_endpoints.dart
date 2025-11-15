/// Centralized billing-related API endpoint paths
class BillingEndpoints {
  BillingEndpoints._();

  /// GET: Fetch all billing items
  static const String getBillingItems = '/api/billing/items';

  /// POST: Create a new billing item
  static const String createBillingItem = '/api/billing/items';

  /// PUT: Update an existing billing item
  static String updateBillingItem(String id) => '/api/billing/items/$id';

  /// DELETE: Delete a billing item
  static String deleteBillingItem(String id) => '/api/billing/items/$id';

  /// GET: Fetch payment history
  static const String getPaymentHistory = '/api/billing/payments';

  /// POST: Record a payment
  static const String recordPayment = '/api/billing/payments';
}
