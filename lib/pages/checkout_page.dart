import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/cart_service.dart';
import '../models/cart_item_model.dart';
import 'login_page.dart';  // إضافة استيراد صفحة تسجيل الدخول
import '../utils/notifications.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _setAsDefault = false;
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isProcessing = false;  // متغير للتحقق من حالة معالجة الطلب

  @override
  void initState() {
    super.initState();
    // تحميل العنوان الافتراضي إذا كان موجوداً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      if (appState.defaultAddress != null) {
        _addressController.text = appState.defaultAddress!.address;
        _phoneController.text = appState.defaultAddress!.phone;
        _notesController.text = appState.defaultAddress!.notes ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0 && !_validateAddressStep()) return;
            
            setState(() {
              if (_currentStep < 2) {
                _currentStep++;
              } else {
                _submitOrder();
              }
            });
          },
          onStepCancel: () {
            setState(() {
              if (_currentStep > 0) {
                _currentStep--;
              }
            });
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E58A8),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _currentStep == 2 ? 'تأكيد الطلب' : 'التالي',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: const BorderSide(color: Color(0xFF6E58A8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'السابق',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6E58A8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('عنوان التوصيل'),
              subtitle: const Text('أدخل عنوان التوصيل ورقم الهاتف'),
              content: _buildAddressStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('طريقة الدفع'),
              subtitle: const Text('اختر طريقة الدفع المناسبة'),
              content: _buildPaymentMethod(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('مراجعة الطلب'),
              subtitle: const Text('راجع تفاصيل طلبك قبل التأكيد'),
              content: _buildOrderSummary(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'العنوان بالتفصيل',
            hintText: 'مثال: شارع 9، المعادي، القاهرة',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال العنوان';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            hintText: 'مثال: 0599123456',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال رقم الهاتف';
            }
            // التحقق من صحة رقم الهاتف الفلسطيني
            // يبدأ بـ 059 أو 056
            if (!RegExp(r'^05[96][0-9]{7}$').hasMatch(value)) {
              return 'يرجى إدخال رقم هاتف فلسطيني صحيح';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'ملاحظات إضافية (اختياري)',
            hintText: 'مثال: بجوار مسجد...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _setAsDefault,
          onChanged: (value) {
            setState(() {
              _setAsDefault = value ?? false;
            });
          },
          title: const Text('تعيين كعنوان افتراضي'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  bool _validateAddressStep() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    return true;
  }

  Widget _buildPaymentMethod() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x1A6E58A8),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.money,
                  color: Color(0xFF6E58A8),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الدفع عند الاستلام',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ادفع نقداً عند استلام طلبك',
                    style: TextStyle(
                      color: Colors.grey,
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

  Widget _buildOrderSummary() {
    final cartItems = context.watch<CartService>().getCartItems();
    final subtotal = context.watch<CartService>().cartTotal;
    const deliveryFee = 30.0;
    final total = subtotal + (subtotal > 500 ? 0 : deliveryFee);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // تفاصيل المنتجات
        ...cartItems.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity} × ${item.price.toStringAsFixed(2)} جنيه',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(item.price * item.quantity).toStringAsFixed(2)} جنيه',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6E58A8),
                ),
              ),
            ],
          ),
        )).toList(),

        const SizedBox(height: 16),

        // ملخص السعر
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المجموع الفرعي',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${subtotal.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'رسوم التوصيل',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    subtotal > 500 ? 'مجاناً' : '${deliveryFee.toStringAsFixed(2)} جنيه',
                    style: TextStyle(
                      color: subtotal > 500 ? Colors.green : null,
                      fontWeight: subtotal > 500 ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الإجمالي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF6E58A8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // معلومات التوصيل
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'معلومات التوصيل',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_addressController.text),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(_phoneController.text),
                ],
              ),
              if (_notesController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.note, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_notesController.text),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitOrder() async {
    // التحقق من أن الطلب لا يتم معالجته حالياً
    if (_isProcessing) return;

    if (!_validateAddressStep()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appState = Provider.of<AppState>(context, listen: false);
    final cartService = Provider.of<CartService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _isProcessing = true;  // تعيين حالة المعالجة
    });

    try {
      final orderId = await appState.createOrder(
        shippingAddress: _addressController.text,
        phone: _phoneController.text,
        deliveryFee: _getDeliveryFee(),
        cartService: cartService,
      );

      if (!mounted) return;

      // التوجه إلى صفحة نجاح الطلب
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessPage(orderId: orderId),
        ),
        (route) => false,  // إزالة جميع الصفحات السابقة من المكدس
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessing = false;  // إعادة تعيين حالة المعالجة
        });
      }
    }
  }

  double _getDeliveryFee() {
    final cartService = Provider.of<CartService>(context, listen: false);
    final subtotal = cartService.cartTotal;
    return subtotal > 500 ? 0.0 : 30.0;  // مجاني للطلبات أكثر من 500 جنيه
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}