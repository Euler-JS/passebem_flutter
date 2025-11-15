import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/subscription_provider.dart';
import '../Model/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionPlansPage extends StatefulWidget {
  const SubscriptionPlansPage({super.key});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  final SubscriptionProvider _subscriptionProvider = SubscriptionProvider();
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessingPayment = false;
  
  // State variables
  bool isLoading = false;
  String? errorMessage;
  List<SubscriptionPlan> plans = [];
  int selectedPlanIndex = -1;
  int selectedPaymentMethod = 0;
  
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
  final TextEditingController phoneController = TextEditingController();

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'M-Pesa',
      'icon': Icons.phone_android,
      'description': 'Pague com seu telefone',
      'color': Color(0xFF00A651),
    },
    {
      'name': 'Cartão',
      'icon': Icons.credit_card,
      'description': 'Visa/Mastercard',
      'color': Color(0xFF1976D2),
    },
  ];

  final List<String> benefits = [
    'Acesso ilimitado a todas as notícias premium',
    'Conteúdo exclusivo dos melhores jornalistas moçambicanos',
    'Notícias locais e internacionais em tempo real',
    'Leitura offline - baixe e leia sem internet',
    'Experiência sem anúncios publicitários',
    'Newsletter semanal com resumo das principais notícias',
    'Acesso antecipado a novos recursos e seções',
    'Suporte prioritário via WhatsApp e email',
  ];

  Future<void> _loadPlans() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await SubscriptionService.getSubscriptionPlans();
      if (response != null && response.isSuccess) {
        setState(() {
          plans = SubscriptionService.sortPlansByRecommendation(response.data);
          isLoading = false;
          // Selecionar o plano mensal (popular) por padrão
          selectedPlanIndex = plans.indexWhere((plan) => plan.isPopular);
          if (selectedPlanIndex == -1 && plans.isNotEmpty) {
            selectedPlanIndex = 0;
          }
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao carregar planos de assinatura';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro de conexão: $e';
        isLoading = false;
      });
    }
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
          ),
          onPressed: () => Navigator.pop(context),
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC7A87B)),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPlans,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC7A87B),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header
                        buildHeader(),
                        
                        const SizedBox(height: 30),
                        
                        // Planos
                        buildPlansSection(),
                        
                        const SizedBox(height: 30),
                        
                        // Métodos de pagamento
                        buildPaymentMethodsSection(),
                        
                        const SizedBox(height: 30),
                        
                        // Benefícios
                        buildBenefitsSection(),
                        
                        const SizedBox(height: 30),
                        
                        // Botão de assinatura
                        buildSubscribeButton(),
                        
                        const SizedBox(height: 20),
                        
                        // Termos e condições
                        buildTermsAndConditions(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget buildHeader() {
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

  Widget buildPlansSection() {
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
        ...plans.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: buildPlanCard(index),
          );
        }).toList(),
      ],
    );
  }

  Widget buildPlanCard(int index) {
    final plan = plans[index];
    final isSelected = selectedPlanIndex == index;
    final isPopular = plan.isPopular;
    
    // Calcular desconto se não for o plano mensal
    final monthlyPlan = plans.firstWhere(
      (p) => p.type == 'monthly', 
      orElse: () => plans.first,
    );
    final discount = SubscriptionService.calculateDiscount(plan, monthlyPlan);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? plan.planColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? plan.planColor 
                : plan.planColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? plan.planColor.withOpacity(0.3)
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
                  color: isSelected ? Colors.transparent : plan.planColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: plan.planColor,
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
                            color: isSelected ? Colors.white : plan.planColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'POPULAR',
                            style: TextStyle(
                              color: isSelected ? plan.planColor : Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (plan.isBestValue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'MELHOR VALOR',
                            style: TextStyle(
                              color: isSelected ? Colors.amber : Colors.white,
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
                  
                  // Desconto (se houver)
                  if (discount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Economize ${discount.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? Colors.white 
                            : Colors.green,
                      ),
                    ),
                  ],
                  
                  // Valor por dia
                  const SizedBox(height: 4),
                  Text(
                    plan.formattedPricePerDay,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.8)
                          : const Color(0xFF333333).withOpacity(0.6),
                    ),
                  ),
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
                  plan.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected 
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF333333).withOpacity(0.7),
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentMethodsSection() {
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
        ...paymentMethods.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: buildPaymentMethodCard(index),
          );
        }).toList(),
      ],
    );
  }

  Widget buildPaymentMethodCard(int index) {
    final method = paymentMethods[index];
    final isSelected = selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? method['color'].withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? method['color'] 
                : const Color(0xFFC7A87B).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? method['color'].withOpacity(0.2)
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
                color: isSelected ? method['color'] : Colors.transparent,
                border: Border.all(
                  color: isSelected ? method['color'] : const Color(0xFFC7A87B),
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
                color: method['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                method['icon'],
                color: method['color'],
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
                    method['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? method['color'] : const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method['description'],
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

  Widget buildBenefitsSection() {
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

  Widget buildSubscribeButton() {
    if (selectedPlanIndex < 0 || selectedPlanIndex >= plans.length) {
      return const SizedBox.shrink();
    }
    
    final selectedPlan = plans[selectedPlanIndex];
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            selectedPlan.planColor,
            selectedPlan.planColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: selectedPlan.planColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          _processPurchase();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selectedPlan.planIcon,
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

  Widget buildTermsAndConditions() {
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
    if (selectedPlanIndex < 0 || selectedPlanIndex >= plans.length) return;
    
    final selectedPlan = plans[selectedPlanIndex];
    
    if (selectedPaymentMethod == 0) {
      // M-Pesa
      _processMpesaPayment(selectedPlan);
    } else {
      // Cartão - mostrar simulação simples
      _showCardPaymentDialog(selectedPlan);
    }
  }

  void _processMpesaPayment(SubscriptionPlan plan) {
    // Dialog para inserir número de telefone
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
              Icon(
                Icons.phone_android,
                color: const Color(0xFF00A651),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: plan.planColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Número de telefone M-Pesa:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Ex: 845640694',
                  prefixText: '+258 ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '• Certifique-se de que tem saldo suficiente\n• Você receberá um SMS de confirmação\n• O pagamento será processado automaticamente',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                phoneController.clear();
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF333333)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, insira seu número de telefone'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                if (!SubscriptionService.isValidMpesaNumber(phoneController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Número de telefone inválido. Use um número moçambicano válido.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                Navigator.pop(context);
                _initializeMpesaPayment(plan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A651),
                foregroundColor: Colors.white,
              ),
              child: const Text('Pagar com M-Pesa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeMpesaPayment(SubscriptionPlan plan) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00A651),
        ),
      ),
    );

    try {
      final formattedPhone = SubscriptionService.formatMpesaNumber(phoneController.text);
      
      final response = await SubscriptionService.processMpesaPayment(
        depositId: plan.id,
        phoneNumber: formattedPhone,
      );

      Navigator.pop(context); // Fechar loading

      if (response.isSuccess) {
        _showMpesaSuccessDialog(plan, response);
      } else {
        _showErrorDialog(response.message);
      }
    } catch (e) {
      Navigator.pop(context); // Fechar loading
      _showErrorDialog('Erro ao processar pagamento: $e');
    }
  }

  void _showMpesaSuccessDialog(SubscriptionPlan plan, MpesaPaymentResponse response) {
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
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Pagamento Iniciado!',
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
                'Pagamento M-Pesa para ${plan.name} foi iniciado com sucesso!',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A651).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plano: ${plan.name}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Valor: ${plan.formattedPrice}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Telefone: +258 ${phoneController.text}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (response.data != null)
                      Text(
                        'ID da transação: ${response.data!.transactionId}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Verifique seu telefone para confirmar o pagamento. Sua assinatura será ativada automaticamente após a confirmação.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                phoneController.clear();
                Navigator.of(context).pop(); // Fechar dialog
                Navigator.of(context).pop(); // Voltar para a tela anterior
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A651),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Entendido',
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

  void _showCardPaymentDialog(SubscriptionPlan plan) {
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
                Icons.info_outline,
                color: Color(0xFF1976D2),
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Pagamento por Cartão',
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: plan.planColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pagamento por cartão será implementado em breve. Por enquanto, use M-Pesa para assinar.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Entendido'),
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
                'Erro no Pagamento',
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
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}
