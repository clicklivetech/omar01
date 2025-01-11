import 'package:flutter/material.dart';
import '../providers/app_state.dart';
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
        const Text(
          'طريقة الدفع',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E58A8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.money,
                    color: Color(0xFF6E58A8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'معلومات مهمة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• يرجى تجهيز المبلغ المطلوب عند التوصيل',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '• سيتم التحقق من المنتجات قبل الدفع',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '• يمكنك إلغاء الطلب في حال عدم رضاك عن المنتجات',
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
    final appState = context.watch<AppState>();
    final cartItems = appState.cartItems;
    final subtotal = appState.cartTotal;
    const shippingFee = 30.0;
    final total = subtotal + shippingFee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // عنوان القسم
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6E58A8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.shopping_cart_checkout, 
                color: Color(0xFF6E58A8),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'مراجعة الطلب',
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

        // معلومات التوصيل
        if (appState.defaultAddress != null) ...[
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'عنوان التوصيل',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(right: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appState.defaultAddress!.name),
                      Text(appState.defaultAddress!.phone),
                      Text(appState.defaultAddress!.address),
                      if (appState.defaultAddress!.notes != null && appState.defaultAddress!.notes!.isNotEmpty)
                        Text(appState.defaultAddress!.notes!),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],

        // المنتجات
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'المنتجات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${cartItems.length} منتج',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              ...cartItems.map((item) => Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
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
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'الكمية: ${appState.getCartItemQuantity(item.id)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.price * appState.getCartItemQuantity(item.id)} جنيه',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.oldPrice != null) 
                          Text(
                            '${item.oldPrice} جنيه',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
        SizedBox(height: 16),

        // ملخص الحساب
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المجموع الفرعي',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '$subtotal جنيه',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'رسوم التوصيل',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '$shippingFee جنيه',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجمالي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$total جنيه',
                    style: TextStyle(
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
        SizedBox(height: 16),

        // طريقة الدفع
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF6E58A8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: Color(0xFF6E58A8),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الدفع عند الاستلام',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ادفع نقداً عند استلام طلبك',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
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
    if (_currentStep == 2) {
      // عرض مربع حوار للتأكيد
      final mounted = context.mounted;
      if (!mounted) return;
      
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد الطلب'),
          content: const Text('هل أنت متأكد من إتمام الطلب؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E58A8),
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        if (!context.mounted) return;
        // عرض مؤشر التحميل
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final appState = context.read<AppState>();
        
        // إنشاء الطلب
        final orderId = await appState.createOrder(
          shippingAddress: _addressController.text,
          phone: _phoneController.text,
          deliveryFee: 30.0,
        );

        if (!context.mounted) return;
        // إغلاق مؤشر التحميل
        Navigator.of(context).pop();

        // عرض رسالة النجاح مع رقم الطلب
        if (!context.mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('تم تأكيد الطلب'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تم تأكيد طلبك بنجاح!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: Color(0xFF6E58A8), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'رقم الطلب: $orderId',
                        style: TextStyle(
                          color: Color(0xFF6E58A8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم توصيل طلبك خلال 25-40 دقيقة من وقت التأكيد',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'وقت التأكيد: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone_android, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم إرسال تفاصيل الطلب وتحديثات الحالة إلى رقم هاتفك',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // العودة للصفحة الرئيسية
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // تحديث مؤشر الصفحة للانتقال إلى صفحة الطلبات
                  appState.setCurrentPageIndex(3);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E58A8),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 45),
                ),
                child: const Text('عرض تفاصيل الطلب'),
              ),
            ],
          ),
        );

        // مسح السلة
        appState.clearCart();
        
      } catch (e) {
        if (!context.mounted) return;
        // إغلاق مؤشر التحميل إذا كان مفتوحاً
        Navigator.of(context).pop();
        
        // عرض رسالة الخطأ
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تأكيد الطلب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
