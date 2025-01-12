import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../services/cart_service.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  final _addressFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _useNewAddress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      final defaultAddress = appState.defaultAddress;
      if (defaultAddress != null) {
        _nameController.text = defaultAddress.name;
        _phoneController.text = defaultAddress.phone;
        _addressController.text = defaultAddress.address;
        _notesController.text = defaultAddress.notes ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
        backgroundColor: const Color(0xFF6E58A8),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              controlsBuilder: (context, details) => const SizedBox.shrink(),
              steps: [
                Step(
                  title: const Text('العنوان'),
                  content: _buildAddressStep(),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('الدفع'),
                  content: _buildPaymentMethod(),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('المراجعة'),
                  content: _buildOrderSummary(),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF6E58A8)),
                      ),
                      child: const Text(
                        'رجوع',
                        style: TextStyle(color: Color(0xFF6E58A8)),
                      ),
                    ),
                  ),
                if (_currentStep > 0)
                  const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 2) {
                        if (_currentStep == 0 && !_validateAddressStep()) {
                          return;
                        }
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        _submitOrder();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E58A8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'تأكيد الطلب' : 'التالي',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    final appState = context.watch<AppState>();
    final addresses = appState.addresses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (addresses.isNotEmpty) ...[
          const Text(
            'العناوين المحفوظة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...addresses.map((address) => Card(
            child: RadioListTile<String>(
              value: address.id,
              groupValue: _useNewAddress ? null : address.id,
              onChanged: (value) {
                setState(() {
                  _useNewAddress = false;
                  _nameController.text = address.name;
                  _phoneController.text = address.phone;
                  _addressController.text = address.address;
                  _notesController.text = address.notes ?? '';
                });
              },
              title: Text(address.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.phone),
                  Text(address.address),
                  if (address.isDefault)
                    const Text(
                      'العنوان الافتراضي',
                      style: TextStyle(
                        color: Color(0xFF6E58A8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              secondary: address.isDefault
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteAddress(address.id),
                    ),
            ),
          )),
          const Divider(height: 32),
        ],

        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _useNewAddress = true;
              _nameController.clear();
              _phoneController.clear();
              _addressController.clear();
              _notesController.clear();
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('إضافة عنوان جديد'),
        ),

        if (_useNewAddress || addresses.isEmpty)
          Form(
            key: _addressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    hintText: 'الاسم بالكامل',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: 'رقم الهاتف',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    hintText: 'العنوان بالتفصيل',
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال العنوان';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    hintText: 'ملاحظات إضافية للتوصيل',
                  ),
                  maxLines: 2,
                ),
                if (_useNewAddress && addresses.isNotEmpty)
                  CheckboxListTile(
                    value: false,
                    onChanged: (value) {
                      if (value == true) {
                        _saveAddress(setAsDefault: true);
                      }
                    },
                    title: const Text('تعيين كعنوان افتراضي'),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  bool _validateAddressStep() {
    if (_useNewAddress || context.read<AppState>().addresses.isEmpty) {
      if (_addressFormKey.currentState?.validate() ?? false) {
        _saveAddress();
        return true;
      }
      return false;
    }
    return true;
  }

  void _saveAddress({bool setAsDefault = false}) {
    final appState = context.read<AppState>();
    appState.addAddress(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      notes: _notesController.text,
      setAsDefault: setAsDefault,
    );
  }

  void _deleteAddress(String id) {
    final appState = context.read<AppState>();
    appState.removeAddress(id);
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6E58A8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.payment,
                color: Color(0xFF6E58A8),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'اختر طريقة الدفع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6E58A8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'ملاحظات هامة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• يرجى تجهيز المبلغ المطلوب نقداً عند التسليم',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '• سيتم التحقق من المنتجات قبل الدفع',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final cartItems = context.watch<CartService>().getCartItems();
    final subtotal = context.watch<CartService>().cartTotal;
    const deliveryFee = 30.0;
    final total = subtotal + deliveryFee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.shopping_cart_outlined, color: Color(0xFF6E58A8)),
                SizedBox(width: 12),
                Text(
                  'ملخص الطلب',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // معلومات التوصيل
        if (context.watch<AppState>().defaultAddress != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF757575), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'عنوان التوصيل',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.watch<AppState>().defaultAddress!.name),
                      Text(context.watch<AppState>().defaultAddress!.phone),
                      Text(context.watch<AppState>().defaultAddress!.address),
                      if (context.watch<AppState>().defaultAddress!.notes != null && 
                          context.watch<AppState>().defaultAddress!.notes!.isNotEmpty)
                        Text(context.watch<AppState>().defaultAddress!.notes!),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

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
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المجموع الفرعي',
                    style: TextStyle(color: Colors.grey),
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
      ],
    );
  }

  Future<void> _submitOrder() async {
    if (!_validateAddressStep()) return;

    if (!mounted) return;
    BuildContext currentContext = context;
    
    final cartService = Provider.of<CartService>(currentContext, listen: false);
    if (cartService.getCartItems().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('السلة فارغة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // عرض مؤشر التحميل
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (!mounted) return;
    currentContext = context;
    final appState = Provider.of<AppState>(currentContext, listen: false);
    
    try {
      // حساب رسوم التوصيل بناءً على المجموع
      final subtotal = cartService.cartTotal;
      final deliveryFee = subtotal > 500 ? 0.0 : 30.0;  // مجاني للطلبات أكثر من 500 جنيه

      // إنشاء الطلب
      final orderId = await appState.createOrder(
        shippingAddress: _addressController.text,
        phone: _phoneController.text,
        deliveryFee: deliveryFee,
      );

      if (!mounted) return;
      currentContext = context;

      // مسح السلة بعد إتمام الطلب بنجاح
      await cartService.clearCart();

      if (!mounted) return;
      // عرض رسالة النجاح مع رقم الطلب
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('تم إنشاء الطلب بنجاح'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم الطلب: $orderId'),
              const SizedBox(height: 8),
              Text(
                deliveryFee == 0 
                  ? 'التوصيل مجاني!'
                  : 'رسوم التوصيل: ${deliveryFee.toStringAsFixed(2)} جنيه',
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      currentContext = context;
      
      // عرض رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إنشاء الطلب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
