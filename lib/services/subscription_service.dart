// lib/services/subscription_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/subscription_model.dart';

class SubscriptionService {
  static const String baseUrl = 'https://tsevelenews.tsevele.co.mz/api';
  static const String _tokenKey = 'auth_token';
  
  // Headers padrão
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers com autenticação
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final baseHeaders = headers;
    if (token != null) {
      baseHeaders['Authorization'] = 'Bearer $token';
    }
    return baseHeaders;
  }

  // Obter todos os planos de assinatura
  static Future<SubscriptionPlansResponse?> getSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/plans'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SubscriptionPlansResponse.fromJson(jsonData);
      } else {
        print('Error getting subscription plans: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting subscription plans: $e');
      return null;
    }
  }

  // Obter métodos de pagamento disponíveis
  static Future<PaymentMethodsResponse?> getPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/payment-methods'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PaymentMethodsResponse.fromJson(jsonData);
      } else {
        print('Error getting payment methods: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting payment methods: $e');
      return null;
    }
  }

  // Criar subscrição (primeiro passo)
  static Future<SubscriptionCreateResponse> createSubscription({
    required int planType,
    required int paymentMethodCode,
    required int methodCode,
    required String currency,
  }) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final request = SubscriptionRequest(
        planType: planType,
        paymentMethodCode: paymentMethodCode,
        methodCode: methodCode,
        currency: currency,
      );
      
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/subscribe'),
        headers: authHeaders,
        body: json.encode(request.toJson()),
      );
      
      final jsonData = json.decode(response.body);
      return SubscriptionCreateResponse.fromJson(jsonData);
      
    } catch (e) {
      return SubscriptionCreateResponse(
        status: 'error',
        message: 'Erro de conexão: $e',
      );
    }
  }

  // Processar pagamento M-Pesa (segundo passo)
  static Future<MpesaPaymentResponse> processMpesaPayment({
    required int depositId,
    required String phoneNumber,
  }) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final request = MpesaPaymentRequest(
        phoneNumber: phoneNumber,
      );
      
      final response = await http.post(
        Uri.parse('$baseUrl/payments/process-mpesa/$depositId'),
        headers: authHeaders,
        body: json.encode(request.toJson()),
      );
      
      final jsonData = json.decode(response.body);
      return MpesaPaymentResponse.fromJson(jsonData);
      
    } catch (e) {
      return MpesaPaymentResponse(
        status: 'error',
        message: 'Erro de conexão: $e',
      );
    }
  }

  // Verificar status da subscrição do usuário
  static Future<SubscriptionStatusResponse?> getUserSubscriptionStatus() async {
    print('[DEBUG] getUserSubscriptionStatus called');
    try {
      final authHeaders = await getAuthHeaders();
      print('[DEBUG] Auth headers: $authHeaders');
      
      final uri = Uri.parse('$baseUrl/subscriptions/status');
      print('[DEBUG] Request URL: $uri');
      
      final response = await http.get(uri, headers: authHeaders);
      
      print('[DEBUG] Response status code: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('[DEBUG] Parsed JSON data: $jsonData');
        print('[DEBUG] JSON data type: ${jsonData.runtimeType}');
        final result = SubscriptionStatusResponse.fromJson(jsonData);
        print('[DEBUG] Created SubscriptionStatusResponse: $result');
        return result;
      } else {
        print('[ERROR] HTTP error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('[ERROR] Exception in getUserSubscriptionStatus: $e');
      print('[ERROR] Stack trace: $stackTrace');
      return null;
    }
  }

  // Obter assinaturas do usuário
  static Future<List<UserSubscription>> getUserSubscriptions() async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/user'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          final List<dynamic> subscriptionsData = jsonData['data'] ?? [];
          return subscriptionsData
              .map((item) => UserSubscription.fromJson(item))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting user subscriptions: $e');
      return [];
    }
  }

  // Verificar se usuário tem assinatura ativa
  static Future<bool> hasActiveSubscription() async {
    try {
      final subscriptions = await getUserSubscriptions();
      return subscriptions.any((sub) => sub.isActive);
    } catch (e) {
      print('Error checking active subscription: $e');
      return false;
    }
  }

  // Obter assinatura ativa atual
  static Future<UserSubscription?> getActiveSubscription() async {
    try {
      final subscriptions = await getUserSubscriptions();
      return subscriptions.firstWhere(
        (sub) => sub.isActive,
        orElse: () => throw StateError('No active subscription found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Cancelar assinatura
  static Future<bool> cancelSubscription(int subscriptionId) async {
    try {
      final authHeaders = await getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/$subscriptionId/cancel'),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['status'] == 'success';
      }
      
      return false;
    } catch (e) {
      print('Error canceling subscription: $e');
      return false;
    }
  }

  // Validar número de telefone para M-Pesa
  static bool isValidMpesaNumber(String phoneNumber) {
    // Remove espaços e caracteres especiais
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Verifica se é um número moçambicano válido
    if (cleanNumber.startsWith('+258')) {
      final number = cleanNumber.substring(4);
      return number.length == 9 && (number.startsWith('8') || number.startsWith('2'));
    }
    
    if (cleanNumber.startsWith('258')) {
      final number = cleanNumber.substring(3);
      return number.length == 9 && (number.startsWith('8') || number.startsWith('2'));
    }
    
    if (cleanNumber.length == 9 && (cleanNumber.startsWith('8') || cleanNumber.startsWith('2'))) {
      return true;
    }
    
    return false;
  }

  // Formatar número de telefone para M-Pesa
  static String formatMpesaNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.startsWith('258') && cleanNumber.length == 12) {
      return cleanNumber.substring(3);
    }
    
    if (cleanNumber.length == 9) {
      return cleanNumber;
    }
    
    return phoneNumber; // Retorna original se não conseguir formatar
  }

  // Calcular desconto percentual em relação ao plano mensal
  static double calculateDiscount(SubscriptionPlan plan, SubscriptionPlan monthlyPlan) {
    if (plan.id == monthlyPlan.id) return 0.0;
    
    final monthlyPricePerDay = monthlyPlan.pricePerDay;
    final planPricePerDay = plan.pricePerDay;
    
    if (monthlyPricePerDay > planPricePerDay) {
      return ((monthlyPricePerDay - planPricePerDay) / monthlyPricePerDay) * 100;
    }
    
    return 0.0;
  }

  // Ordenar planos por popularidade/recomendação
  static List<SubscriptionPlan> sortPlansByRecommendation(List<SubscriptionPlan> plans) {
    final sortedPlans = List<SubscriptionPlan>.from(plans);
    
    sortedPlans.sort((a, b) {
      // Prioridade: Mensal (popular), Anual (melhor valor), outros por duração
      if (a.isPopular) return -1;
      if (b.isPopular) return 1;
      if (a.isBestValue) return -1;
      if (b.isBestValue) return 1;
      return a.durationDays.compareTo(b.durationDays);
    });
    
    return sortedPlans;
  }
}
