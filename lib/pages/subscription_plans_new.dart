import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import '../Model/subscription_model.dart';
import '../services/auth_provider.dart';
import '../services/subscription_provider.dart';
import '../main_navigation.dart';

class SubscriptionPlansPage extends StatefulWidget {
  const SubscriptionPlansPage({super.key});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  final SubscriptionProvider _subscriptionProvider = SubscriptionProvider();
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessingPayment = false;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _subscriptionProvider.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF333333),
            size: 20,
          ),
          onPressed: () {
            // Verificar se pode voltar normalmente
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Se não pode, ir para a home
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                (route) => false,
              );
            }
          },
        ),
        title: const Text(
          'Planos Premium',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_subscriptionProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC7A87B),
        ),
      );
    }

    if (_subscriptionProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _subscriptionProvider.errorMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7A87B),
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 30),
            
            // Verificar se usuário já tem subscrição ativa
            if (_subscriptionProvider.hasActiveSubscription) ...[
              _buildActiveSubscriptionCard(),
              const SizedBox(height: 30),
            ],
            
            // Planos
            _buildPlansSection(),
            
            const SizedBox(height: 30),
            
            // Métodos de pagamento
            _buildPaymentMethodsSection(),
            
            const SizedBox(height: 30),
            
            // Benefícios
            _buildBenefitsSection(),
            
            const SizedBox(height: 30),
            
            // Botão de assinatura
            _buildSubscribeButton(),
            
            const SizedBox(height: 20),
            
            // Termos e condições
            _buildTermsAndConditions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Ícone premium
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFC7A87B),
                Color(0xFF8B5E3C),
              ],
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 48,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Título
        const Text(
          'Desbloqueie Todo\no Conteúdo Premium',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Subtítulo
        Text(
          'Tenha acesso ilimitado às melhores notícias de Moçambique e do mundo',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF333333).withOpacity(0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActiveSubscriptionCard() {
    final subscription = _subscriptionProvider.userSubscriptionStatus?.subscription;
    if (subscription == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Subscrição Ativa',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.planName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Expira em ${subscription.formattedExpireDate}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${subscription.daysRemaining} dias',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'restantes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection() {
    if (_subscriptionProvider.plans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Título da seção
        const Text(
          'Escolha seu plano',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Cards dos planos em lista vertical
        ..._subscriptionProvider.plans.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPlanCard(index),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _subscriptionProvider.plans[index];
    final isSelected = _subscriptionProvider.selectedPlanIndex == index;
    final isPopular = plan.isPopular;
    final discountText = _subscriptionProvider.getDiscountText(plan);

    return GestureDetector(
      onTap: () {
        _subscriptionProvider.selectPlan(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC7A87B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFC7A87B) 
                : const Color(0xFFC7A87B).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? const Color(0xFFC7A87B).withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Círculo de seleção
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFC7A87B),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFFC7A87B),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Informações do plano
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge popular + título
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF333333),
                          ),
                        ),
                      ),
                      if (isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFC7A87B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'POPULAR',
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFC7A87B) : Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Duração
                  Text(
                    plan.formattedDuration,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.8)
                          : const Color(0xFF333333).withOpacity(0.7),
                    ),
                  ),
                  
                  // Economia (se houver)
                  if (discountText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      discountText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? Colors.white 
                            : const Color(0xFF8B5E3C),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Preço
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.formattedPrice,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF333333),
                  ),
                ),
                Text(
                  '/${plan.type}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected 
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF333333).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    if (_subscriptionProvider.paymentMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Título da seção
        const Text(
          'Método de pagamento',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Cards dos métodos de pagamento
        ..._subscriptionProvider.paymentMethods.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPaymentMethodCard(index),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPaymentMethodCard(int index) {
    final method = _subscriptionProvider.paymentMethods[index];
    final isSelected = _subscriptionProvider.selectedPaymentMethodIndex == index;
    final isMpesa = method.methodName.toLowerCase().contains('mpesa') || method.methodName.toLowerCase().contains('m-pesa');

    return GestureDetector(
      onTap: () {
        _subscriptionProvider.selectPaymentMethod(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? (isMpesa ? const Color(0xFF00A651).withOpacity(0.1) : const Color(0xFF1976D2).withOpacity(0.1)) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? (isMpesa ? const Color(0xFF00A651) : const Color(0xFF1976D2))
                : const Color(0xFFC7A87B).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? (isMpesa ? const Color(0xFF00A651).withOpacity(0.2) : const Color(0xFF1976D2).withOpacity(0.2))
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Círculo de seleção
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? (isMpesa ? const Color(0xFF00A651) : const Color(0xFF1976D2)) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? (isMpesa ? const Color(0xFF00A651) : const Color(0xFF1976D2)) : const Color(0xFFC7A87B),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Ícone do método
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMpesa ? const Color(0xFF00A651).withOpacity(0.1) : const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isMpesa ? Icons.phone_android : Icons.credit_card,
                color: isMpesa ? const Color(0xFF00A651) : const Color(0xFF1976D2),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Informações do método
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.methodName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? (isMpesa ? const Color(0xFF00A651) : const Color(0xFF1976D2)) : const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isMpesa ? 'Pague com seu telefone' : 'Visa/Mastercard',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF333333).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      'Acesso ilimitado a todas as notícias premium',
      'Conteúdo exclusivo dos melhores jornalistas moçambicanos',
      'Notícias locais e internacionais em tempo real',
      'Leitura offline - baixe e leia sem internet',
      'Experiência sem anúncios publicitários',
      'Newsletter semanal com resumo das principais notícias',
      'Acesso antecipado a novos recursos e seções',
      'Suporte prioritário via WhatsApp e email',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'O que você ganha com o Premium:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Lista de benefícios
        ...benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7A87B),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  benefit,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildSubscribeButton() {
    final selectedPlan = _subscriptionProvider.selectedPlan;
    
    if (selectedPlan == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC7A87B),
            Color(0xFF8B5E3C),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC7A87B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _processPurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isProcessingPayment
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assinar ${selectedPlan.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Column(
      children: [
        // Informações de pagamento
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.security,
                color: Color(0xFFC7A87B),
                size: 24,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pagamentos Seguros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aceitamos M-Pesa e cartões Visa/Mastercard com segurança SSL',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF333333).withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Termos
        Text(
          'Ao assinar, você concorda com nossos Termos de Uso e Política de Privacidade. Pagamentos processados de forma segura. Você pode cancelar sua assinatura a qualquer momento através do seu perfil.',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF333333).withOpacity(0.6),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Abrir termos de uso
              },
              child: const Text(
                'Termos de Uso',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFC7A87B),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                // Abrir política de privacidade
              },
              child: const Text(
                'Política de Privacidade',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFC7A87B),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _processPurchase() {
    final selectedPlan = _subscriptionProvider.selectedPlan;
    final selectedPaymentMethod = _subscriptionProvider.selectedPaymentMethod;
    
    if (selectedPlan == null || selectedPaymentMethod == null) {
      _showErrorDialog('Selecione um plano e método de pagamento');
      return;
    }
    
    final isMpesa = selectedPaymentMethod.methodName.toLowerCase().contains('mpesa') || 
                   selectedPaymentMethod.methodName.toLowerCase().contains('m-pesa');
    
    if (isMpesa) {
      _processMpesaPayment(selectedPlan);
    } else {
      _processCardPayment(selectedPlan);
    }
  }

  void _processMpesaPayment(SubscriptionPlan plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.phone_android,
                color: Color(0xFF00A651),
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Pagamento M-Pesa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plano: ${plan.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Valor: ${plan.formattedPrice}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo de número de telefone
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Número de telefone',
                  hintText: '84/85XXXXXXX',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _phoneController.clear();
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF333333)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_phoneController.text.isEmpty) {
                  _showErrorDialog('Digite seu número de telefone');
                  return;
                }
                
                if (!_subscriptionProvider.isValidMpesaNumber(_phoneController.text)) {
                  _showErrorDialog('Número de telefone inválido. Use formato: 84XXXXXXX ou 85XXXXXXX');
                  return;
                }
                
                Navigator.pop(context);
                _initiateMpesaPayment(plan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A651),
                foregroundColor: Colors.white,
              ),
              child: const Text('Pagar Agora'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initiateMpesaPayment(SubscriptionPlan plan) async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Primeiro, criar a subscrição
      final subscriptionResponse = await _subscriptionProvider.createSubscription();
      
      if (subscriptionResponse == null || !subscriptionResponse.isSuccess) {
        _showErrorDialog(subscriptionResponse?.message ?? 'Erro ao criar subscrição');
        return;
      }

      // Depois, processar o pagamento M-Pesa
      final phoneNumber = _subscriptionProvider.formatMpesaNumber(_phoneController.text);
      final mpesaResponse = await _subscriptionProvider.processMpesaPayment(
        depositId: subscriptionResponse.data!.depositId,
        phoneNumber: phoneNumber,
      );

      if (mpesaResponse == null || !mpesaResponse.isSuccess) {
        _showErrorDialog(mpesaResponse?.message ?? 'Erro no pagamento M-Pesa');
        return;
      }

      // Pagamento iniciado com sucesso
      _showMpesaInstructionsDialog(plan, mpesaResponse.data!);
      
    } catch (e) {
      _showErrorDialog('Erro de conexão: $e');
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
      _phoneController.clear();
    }
  }

  void _showMpesaInstructionsDialog(SubscriptionPlan plan, MpesaPaymentData paymentData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.phone_android,
                color: Color(0xFF00A651),
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Confirme o Pagamento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instruções:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('1. Abra o aplicativo M-Pesa no seu telefone'),
              const Text('2. Selecione "Pagar Serviços"'),
              const Text('3. Digite o código do comerciante: 171717'),
              Text('4. Valor: ${paymentData.finalAmount} MZN'),
              Text('5. Referência: ${paymentData.transactionId}'),
              const Text('6. Confirme o pagamento'),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Status do Pagamento:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentData.status == 'completed' 
                          ? 'Pagamento confirmado!'
                          : 'Aguardando confirmação...',
                      style: TextStyle(
                        fontSize: 12,
                        color: paymentData.status == 'completed' 
                            ? Colors.green 
                            : const Color(0xFF1E88E5),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (paymentData.status == 'completed') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fechar dialog
                  _showSuccessDialog(plan);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A651),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continuar'),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFF333333)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Simular confirmação após alguns segundos
                  Future.delayed(const Duration(seconds: 3), () {
                    _showSuccessDialog(plan);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A651),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmar Pagamento'),
              ),
            ],
          ],
        );
      },
    );
  }

  void _processCardPayment(SubscriptionPlan plan) {
    final authProvider = AuthProvider.instance;
    final user = authProvider.user;
    
    if (user?.email?.isEmpty ?? true) {
      _showErrorDialog('Usuário não autenticado ou email não disponível');
      return;
    }

    // Generate unique transaction reference
    final uniqueTransRef = PayWithPayStack().generateUuidV4();

    // Convert amount to smallest currency unit (centavos for MZN)
    final amountInCentavos = plan.price * 100;

    setState(() {
      _isProcessingPayment = true;
    });

    PayWithPayStack().now(
      context: context,
      secretKey: "sk_test_d46dd9dc893e03f48c0a818af101063cf0785194", // TODO: Replace with actual Paystack secret key
      customerEmail: user?.email ?? '',
      reference: uniqueTransRef,
      currency: "ZAR",
      amount: amountInCentavos,
      callbackUrl: "https://tsevelenews.tsevele.co.mz/payment/callback", // TODO: Replace with actual callback URL
      transactionCompleted: (paymentData) async {
        debugPrint("Payment completed: $paymentData");
        
        // Create subscription after successful payment
        final subscriptionResponse = await _subscriptionProvider.createSubscription();
        
        if (subscriptionResponse == null || !subscriptionResponse.isSuccess) {
          _showErrorDialog(subscriptionResponse?.message ?? 'Erro ao criar subscrição');
          return;
        }

        setState(() {
          _isProcessingPayment = false;
        });
        
        _showSuccessDialog(plan);
      },
      transactionNotCompleted: (reason) {
        debugPrint("Payment failed: $reason");
        setState(() {
          _isProcessingPayment = false;
        });
        _showErrorDialog('Pagamento não foi concluído: $reason');
      },
    );
  }

  void _showSuccessDialog(SubscriptionPlan plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Pagamento Aprovado!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sua assinatura ${plan.name} foi ativada com sucesso!',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Plano: ${plan.name}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Valor pago: ${plan.formattedPrice}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Método: ${_subscriptionProvider.selectedPaymentMethod?.methodName ?? 'N/A'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recarregando conteúdo premium...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Recarregar dados da subscrição
                await _subscriptionProvider.initialize();
                
                if (mounted) {
                  Navigator.of(context).pop(); // Fechar dialog
                  Navigator.of(context).pop(true); // Voltar para a tela anterior com resultado true
                  
                  // Mostrar mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('Conteúdo premium desbloqueado!'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC7A87B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Erro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}