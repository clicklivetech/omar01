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
        const Text(
          'ملخص الطلب',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // المنتجات
        ...cartItems.map((item) => ListTile(
          leading: SizedBox(
            width: 60,
            height: 60,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(item.name),
          subtitle: Text('الكمية: ${appState.getCartItemQuantity(item.id)}'),
          trailing: Text(
            '${item.price * appState.getCartItemQuantity(item.id)} جنيه',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        )),
        const Divider(),
        // التفاصيل
        ListTile(
          title: const Text('المجموع الفرعي'),
          trailing: Text('$subtotal جنيه'),
        ),
        ListTile(
          title: const Text('رسوم التوصيل'),
          trailing: const Text('$shippingFee جنيه'),
        ),
        const Divider(),
        ListTile(
          title: const Text(
            'الإجمالي',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Text(
            '$total جنيه',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // تفاصيل التوصيل
        const Text(
          'عنوان التوصيل',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nameController.text),
                Text(_phoneController.text),
                Text(_addressController.text),
                if (_notesController.text.isNotEmpty)
                  Text('ملاحظات: ${_notesController.text}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // طريقة الدفع
        const Text(
          'طريقة الدفع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.money),
            title: const Text('الدفع عند الاستلام'),
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
          builder: (context) => AlertDialog(
            title: const Text('تم تأكيد الطلب'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تم تأكيد طلبك بنجاح!'),
                const SizedBox(height: 8),
                Text('رقم الطلب: $orderId'),
                const SizedBox(height: 16),
                const Text('سيتم إرسال تفاصيل الطلب إلى رقم هاتفك.'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // العودة للصفحة الرئيسية
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E58A8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('حسناً'),
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
