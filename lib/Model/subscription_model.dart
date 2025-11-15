// lib/Model/subscription_model.dart
import 'package:flutter/material.dart';

class SubscriptionPlan {
  final int id;
  final String type;
  final String name;
  final double price;
  final int durationDays;
  final String description;

  SubscriptionPlan({
    required this.id,
    required this.type,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.description,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      durationDays: json['duration_days'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'price': price.toString(),
      'duration_days': durationDays,
      'description': description,
    };
  }

  // Método para obter a cor do plano baseada no tipo
  Color get planColor {
    switch (type) {
      case 'weekly':
        return const Color(0xFF4CAF50); // Verde
      case 'monthly':
        return const Color(0xFF2196F3); // Azul
      case 'quarterly':
        return const Color(0xFFFF9800); // Laranja
      case 'semi_annual':
        return const Color(0xFF9C27B0); // Roxo
      case 'yearly':
        return const Color(0xFFC7A87B); // Dourado
      default:
        return const Color(0xFF757575); // Cinza
    }
  }

  // Método para obter ícone do plano
  IconData get planIcon {
    switch (type) {
      case 'weekly':
        return Icons.calendar_view_week;
      case 'monthly':
        return Icons.calendar_view_month;
      case 'quarterly':
        return Icons.calendar_today;
      case 'semi_annual':
        return Icons.event_note;
      case 'yearly':
        return Icons.event;
      default:
        return Icons.star;
    }
  }

  // Método para obter duração formatada
  String get formattedDuration {
    if (durationDays < 30) {
      return '$durationDays dias';
    } else if (durationDays < 365) {
      int months = (durationDays / 30).round();
      return months == 1 ? '1 mês' : '$months meses';
    } else {
      int years = (durationDays / 365).round();
      return years == 1 ? '1 ano' : '$years anos';
    }
  }

  // Método para obter preço formatado
  String get formattedPrice {
    return 'MT ${price.toStringAsFixed(2)}';
  }

  // Método para calcular valor por dia
  double get pricePerDay {
    return price / durationDays;
  }

  // Método para obter valor por dia formatado
  String get formattedPricePerDay {
    return 'MT ${pricePerDay.toStringAsFixed(2)}/dia';
  }

  // Verificar se é o plano mais popular (mensal)
  bool get isPopular {
    return type == 'monthly';
  }

  // Verificar se é o melhor valor (anual)
  bool get isBestValue {
    return type == 'yearly';
  }
}

class SubscriptionPlansResponse {
  final String status;
  final List<SubscriptionPlan> data;
  final String message;

  SubscriptionPlansResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlansResponse(
      status: json['status'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => SubscriptionPlan.fromJson(item))
          .toList() ?? [],
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => status == 'success';
}

// Modelo para criar subscrição
class SubscriptionRequest {
  final int planType;
  final int paymentMethodCode;
  final int methodCode;
  final String currency;

  SubscriptionRequest({
    required this.planType,
    required this.paymentMethodCode,
    required this.methodCode,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan_type': planType,
      'payment_method_code': paymentMethodCode,
      'method_code': methodCode,
      'currency': currency,
    };
  }
}

class SubscriptionCreateResponse {
  final String status;
  final SubscriptionDepositData? data;
  final String message;

  SubscriptionCreateResponse({
    required this.status,
    this.data,
    required this.message,
  });

  factory SubscriptionCreateResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionCreateResponse(
      status: json['status'] ?? '',
      data: json['data'] != null 
          ? SubscriptionDepositData.fromJson(json['data']) 
          : null,
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => status == 'success';
}

class SubscriptionDepositData {
  final int depositId;
  final String transactionId;
  final double amount;
  final int status;
  final String planName;

  SubscriptionDepositData({
    required this.depositId,
    required this.transactionId,
    required this.amount,
    required this.status,
    required this.planName,
  });

  factory SubscriptionDepositData.fromJson(Map<String, dynamic> json) {
    return SubscriptionDepositData(
      depositId: json['deposit_id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      amount: PaymentMethod._parseDouble(json['amount']) ?? 0.0,
      status: json['status'] ?? 0,
      planName: json['plan_name'] ?? '',
    );
  }
}

// Modelo para pagamento M-Pesa
class MpesaPaymentRequest {
  final String phoneNumber;

  MpesaPaymentRequest({
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
    };
  }
}

class MpesaPaymentResponse {
  final String status;
  final MpesaPaymentData? data;
  final String message;

  MpesaPaymentResponse({
    required this.status,
    this.data,
    required this.message,
  });

  factory MpesaPaymentResponse.fromJson(Map<String, dynamic> json) {
    return MpesaPaymentResponse(
      status: json['status'] ?? '',
      data: json['data'] != null 
          ? MpesaPaymentData.fromJson(json['data']) 
          : null,
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => status == 'success';
}

class MpesaPaymentData {
  final int depositId;
  final String transactionId;
  final String amount;
  final String finalAmount;
  final String mpesaReference;
  final String status;

  MpesaPaymentData({
    required this.depositId,
    required this.transactionId,
    required this.amount,
    required this.finalAmount,
    required this.mpesaReference,
    required this.status,
  });

  factory MpesaPaymentData.fromJson(Map<String, dynamic> json) {
    return MpesaPaymentData(
      depositId: json['deposit_id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      finalAmount: json['final_amount']?.toString() ?? '0',
      mpesaReference: json['mpesa_reference'] ?? '',
      status: json['status'] ?? '',
    );
  }

  bool get isCompleted => status == 'completed';
}

// Modelo para histórico de assinaturas do usuário
class UserSubscription {
  final int id;
  final int userId;
  final int planId;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String? paymentMethod;
  final String? transactionId;
  final SubscriptionPlan? plan;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.paymentMethod,
    this.transactionId,
    this.plan,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      planId: json['plan_id'] ?? 0,
      status: json['status'] ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      plan: json['plan'] != null ? SubscriptionPlan.fromJson(json['plan']) : null,
    );
  }

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());
  bool get isExpired => endDate.isBefore(DateTime.now());
  
  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  String get formattedAmount => 'MT ${amount.toStringAsFixed(2)}';
}

// Modelo para métodos de pagamento
class PaymentMethod {
  final int methodCode;
  final String methodName;
  final String currency;
  final String symbol;
  final double minAmount;
  final double maxAmount;
  final double fixedCharge;
  final double percentCharge;
  final double rate;
  final String? image;

  PaymentMethod({
    required this.methodCode,
    required this.methodName,
    required this.currency,
    required this.symbol,
    required this.minAmount,
    required this.maxAmount,
    required this.fixedCharge,
    required this.percentCharge,
    required this.rate,
    this.image,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      methodCode: json['method_code'] ?? 0,
      methodName: json['method_name'] ?? '',
      currency: json['currency'] ?? '',
      symbol: json['symbol'] ?? '',
      minAmount: _parseDouble(json['min_amount']) ?? 0.0,
      maxAmount: _parseDouble(json['max_amount']) ?? 0.0,
      fixedCharge: _parseDouble(json['fixed_charge']) ?? 0.0,
      percentCharge: _parseDouble(json['percent_charge']) ?? 0.0,
      rate: _parseDouble(json['rate']) ?? 1.0,
      image: json['image'],
    );
  }

  // Função auxiliar para converter qualquer valor para double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class PaymentMethodsResponse {
  final String status;
  final List<PaymentMethod> data;
  final String message;

  PaymentMethodsResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsResponse(
      status: json['status'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => PaymentMethod.fromJson(item))
          .toList() ?? [],
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => status == 'success';
}

// Modelo para status de subscrição do usuário
class UserSubscriptionStatus {
  final bool hasActiveSubscription;
  final ActiveSubscription? subscription;

  UserSubscriptionStatus({
    required this.hasActiveSubscription,
    this.subscription,
  });

  factory UserSubscriptionStatus.fromJson(Map<String, dynamic> json) {
    print('[DEBUG] UserSubscriptionStatus.fromJson called');
    print('[DEBUG] JSON: $json');
    print('[DEBUG] has_active_subscription: ${json['has_active_subscription']} (type: ${json['has_active_subscription'].runtimeType})');
    print('[DEBUG] subscription: ${json['subscription']}');
    
    final hasActive = json['has_active_subscription'] == true || 
                      json['has_active_subscription'] == 'true' ||
                      json['has_active_subscription'] == 1;
    
    print('[DEBUG] Parsed hasActive: $hasActive');
    
    return UserSubscriptionStatus(
      hasActiveSubscription: hasActive,
      subscription: json['subscription'] != null 
          ? ActiveSubscription.fromJson(json['subscription']) 
          : null,
    );
  }
}

class ActiveSubscription {
  final int id;
  final int planType;
  final String planName;
  final double planPrice;
  final DateTime expireDate;
  final int daysRemaining;
  final DateTime createdAt;
  final SubscriptionPlan planDetails;

  ActiveSubscription({
    required this.id,
    required this.planType,
    required this.planName,
    required this.planPrice,
    required this.expireDate,
    required this.daysRemaining,
    required this.createdAt,
    required this.planDetails,
  });

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    print('[DEBUG] ActiveSubscription.fromJson called');
    print('[DEBUG] JSON: $json');
    
    // Parse plan_price which can be a string or number
    double parsePlanPrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }
    
    final subscription = ActiveSubscription(
      id: json['id'] ?? 0,
      planType: json['plan_type'] ?? 0,
      planName: json['plan_name'] ?? '',
      planPrice: parsePlanPrice(json['plan_price']),
      expireDate: DateTime.tryParse(json['expire_date'] ?? '') ?? DateTime.now(),
      daysRemaining: json['days_remaining'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      planDetails: SubscriptionPlan.fromJson(json['plan_details'] ?? {}),
    );
    
    print('[DEBUG] Created ActiveSubscription - ID: ${subscription.id}, Days: ${subscription.daysRemaining}, IsActive: ${subscription.isActive}');
    
    return subscription;
  }

  bool get isActive => daysRemaining > 0;
  String get formattedPrice => 'MT ${planPrice.toStringAsFixed(2)}';
  String get formattedExpireDate => 
      '${expireDate.day}/${expireDate.month}/${expireDate.year}';
}

class SubscriptionStatusResponse {
  final String status;
  final UserSubscriptionStatus? data;
  final String message;

  SubscriptionStatusResponse({
    required this.status,
    this.data,
    required this.message,
  });

  factory SubscriptionStatusResponse.fromJson(Map<String, dynamic> json) {
    print('[DEBUG] SubscriptionStatusResponse.fromJson called');
    print('[DEBUG] JSON: $json');
    print('[DEBUG] Status: ${json['status']}');
    print('[DEBUG] Data: ${json['data']}');
    
    return SubscriptionStatusResponse(
      status: json['status'] ?? '',
      data: json['data'] != null 
          ? UserSubscriptionStatus.fromJson(json['data']) 
          : null,
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => status == 'success';
}
