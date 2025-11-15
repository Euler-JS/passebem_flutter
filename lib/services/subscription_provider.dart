// lib/services/subscription_provider.dart
import 'package:flutter/material.dart';
import '../Model/subscription_model.dart';
import 'subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<SubscriptionPlan> _plans = [];
  List<PaymentMethod> _paymentMethods = [];
  UserSubscriptionStatus? _userSubscriptionStatus;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Selected values
  int _selectedPlanIndex = 1; // Plano mensal como padrão
  int _selectedPaymentMethodIndex = 0; // M-Pesa como padrão

  // Getters
  List<SubscriptionPlan> get plans => _plans;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  UserSubscriptionStatus? get userSubscriptionStatus => _userSubscriptionStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int get selectedPlanIndex => _selectedPlanIndex;
  int get selectedPaymentMethodIndex => _selectedPaymentMethodIndex;
  
  SubscriptionPlan? get selectedPlan => 
      _plans.isNotEmpty && _selectedPlanIndex < _plans.length 
          ? _plans[_selectedPlanIndex] 
          : null;
          
  PaymentMethod? get selectedPaymentMethod => 
      _paymentMethods.isNotEmpty && _selectedPaymentMethodIndex < _paymentMethods.length 
          ? _paymentMethods[_selectedPaymentMethodIndex] 
          : null;

  bool get hasActiveSubscription => 
      _userSubscriptionStatus?.hasActiveSubscription == true;

  // Setters
  void selectPlan(int index) {
    if (index >= 0 && index < _plans.length) {
      _selectedPlanIndex = index;
      notifyListeners();
    }
  }

  void selectPaymentMethod(int index) {
    if (index >= 0 && index < _paymentMethods.length) {
      _selectedPaymentMethodIndex = index;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Carregar planos de subscrição
  Future<void> loadPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SubscriptionService.getSubscriptionPlans();
      
      if (response != null && response.isSuccess) {
        _plans = response.data;
        
        // Se há planos, garantir que a seleção é válida
        if (_plans.isNotEmpty && _selectedPlanIndex >= _plans.length) {
          _selectedPlanIndex = 0;
        }
      } else {
        _errorMessage = response?.message ?? 'Erro ao carregar planos';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Carregar métodos de pagamento
  Future<void> loadPaymentMethods() async {
    try {
      final response = await SubscriptionService.getPaymentMethods();
      
      if (response != null && response.isSuccess) {
        _paymentMethods = response.data;
        
        // Se há métodos, garantir que a seleção é válida
        if (_paymentMethods.isNotEmpty && _selectedPaymentMethodIndex >= _paymentMethods.length) {
          _selectedPaymentMethodIndex = 0;
        }
      } else {
        // Se não conseguir carregar da API, usar métodos mock
        _loadMockPaymentMethods();
      }
    } catch (e) {
      print('Erro ao carregar métodos de pagamento: $e');
      // Se houver erro, usar métodos mock
      _loadMockPaymentMethods();
    }
    
    notifyListeners();
  }

  // Métodos de pagamento mock para teste
  void _loadMockPaymentMethods() {
    _paymentMethods = [
      PaymentMethod(
        methodCode: 1,
        methodName: 'M-Pesa',
        currency: 'MZN',
        symbol: 'MT',
        minAmount: 10.0,
        maxAmount: 10000.0,
        fixedCharge: 0.0,
        percentCharge: 0.0,
        rate: 1.0,
        image: null,
      ),
      PaymentMethod(
        methodCode: 2,
        methodName: 'Cartão de Crédito',
        currency: 'MZN',
        symbol: 'MT',
        minAmount: 10.0,
        maxAmount: 50000.0,
        fixedCharge: 5.0,
        percentCharge: 3.5,
        rate: 1.0,
        image: null,
      ),
      PaymentMethod(
        methodCode: 3,
        methodName: 'Transferência Bancária',
        currency: 'MZN',
        symbol: 'MT',
        minAmount: 50.0,
        maxAmount: 100000.0,
        fixedCharge: 10.0,
        percentCharge: 0.0,
        rate: 1.0,
        image: null,
      ),
    ];
    
    // Garantir que a seleção é válida
    if (_paymentMethods.isNotEmpty && _selectedPaymentMethodIndex >= _paymentMethods.length) {
      _selectedPaymentMethodIndex = 0;
    }
  }

  // Carregar status da subscrição do usuário
  Future<void> loadUserSubscriptionStatus() async {
    print('[DEBUG] loadUserSubscriptionStatus called');
    try {
      final response = await SubscriptionService.getUserSubscriptionStatus();
      
      print('[DEBUG] Response received - isSuccess: ${response?.isSuccess}');
      print('[DEBUG] Response data: ${response?.data}');
      
      if (response != null && response.isSuccess) {
        _userSubscriptionStatus = response.data;
        print('[DEBUG] Set _userSubscriptionStatus: $_userSubscriptionStatus');
        print('[DEBUG] hasActiveSubscription getter returns: $hasActiveSubscription');
        print('[DEBUG] _userSubscriptionStatus.hasActiveSubscription: ${_userSubscriptionStatus?.hasActiveSubscription}');
        print('[DEBUG] _userSubscriptionStatus.subscription: ${_userSubscriptionStatus?.subscription}');
      } else {
        print('[DEBUG] Response was null or not success');
      }
    } catch (e) {
      print('[ERROR] Erro ao carregar status da subscrição: $e');
      print('[ERROR] Stack trace: ${StackTrace.current}');
    }
    
    print('[DEBUG] Calling notifyListeners()');
    notifyListeners();
  }

  // Criar subscrição
  Future<SubscriptionCreateResponse?> createSubscription() async {
    if (selectedPlan == null || selectedPaymentMethod == null) {
      _errorMessage = 'Selecione um plano e método de pagamento';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SubscriptionService.createSubscription(
        planType: selectedPlan!.id,
        paymentMethodCode: selectedPaymentMethod!.methodCode,
        methodCode: 258, // Código do método conforme documento
        currency: 'MZN',
      );

      if (!response.isSuccess) {
        _errorMessage = response.message;
      }

      _isLoading = false;
      notifyListeners();
      
      return response;
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Processar pagamento M-Pesa
  Future<MpesaPaymentResponse?> processMpesaPayment({
    required int depositId,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SubscriptionService.processMpesaPayment(
        depositId: depositId,
        phoneNumber: phoneNumber,
      );

      if (!response.isSuccess) {
        _errorMessage = response.message;
      } else {
        // Se o pagamento foi bem-sucedido, recarregar status da subscrição
        await loadUserSubscriptionStatus();
      }

      _isLoading = false;
      notifyListeners();
      
      return response;
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Inicializar dados (carregar tudo)
  Future<void> initialize() async {
    await Future.wait([
      loadPlans(),
      loadPaymentMethods(),
      loadUserSubscriptionStatus(),
    ]);
  }

  // Validar número de telefone para M-Pesa
  bool isValidMpesaNumber(String phoneNumber) {
    return SubscriptionService.isValidMpesaNumber(phoneNumber);
  }

  // Formatar número de telefone para M-Pesa
  String formatMpesaNumber(String phoneNumber) {
    return SubscriptionService.formatMpesaNumber(phoneNumber);
  }

  // Calcular valores do pagamento
  Map<String, double> calculatePaymentValues(SubscriptionPlan plan, PaymentMethod? paymentMethod) {
    final baseAmount = plan.price;
    double charge = 0.0;
    
    if (paymentMethod != null) {
      // Calcular taxa baseada no método de pagamento
      charge = paymentMethod.fixedCharge + (baseAmount * paymentMethod.percentCharge / 100);
    }
    
    final finalAmount = baseAmount + charge;
    
    return {
      'baseAmount': baseAmount,
      'charge': charge,
      'finalAmount': finalAmount,
    };
  }

  // Obter texto de economia/desconto para um plano
  String? getDiscountText(SubscriptionPlan plan) {
    if (_plans.isEmpty) return null;
    
    // Encontrar plano mensal para comparação
    final monthlyPlan = _plans.firstWhere(
      (p) => p.type == 'monthly',
      orElse: () => _plans.first,
    );
    
    if (plan.id == monthlyPlan.id) return null;
    
    final discount = SubscriptionService.calculateDiscount(plan, monthlyPlan);
    
    if (discount > 0) {
      return 'Economize ${discount.toStringAsFixed(0)}%';
    }
    
    return null;
  }
}