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
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
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
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
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
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
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
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('رجوع'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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
          'اختر طريقة الدفع',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: RadioListTile<PaymentMethod>(
            value: PaymentMethod.cash,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            title: const Text('الدفع عند الاستلام'),
            subtitle: const Text('ادفع نقداً عند استلام طلبك'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: RadioListTile<PaymentMethod>(
            value: PaymentMethod.creditCard,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            title: const Text('بطاقة ائتمان'),
            subtitle: const Text('ادفع الآن باستخدام بطاقتك'),
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
            leading: Icon(
              _selectedPaymentMethod == PaymentMethod.cash
                  ? Icons.money
                  : Icons.credit_card,
            ),
            title: Text(
              _selectedPaymentMethod == PaymentMethod.cash
                  ? 'الدفع عند الاستلام'
                  : 'بطاقة ائتمان',
            ),
          ),
        ),
      ],
    );
  }

  void _submitOrder() {
    if (_currentStep == 2) {
      final appState = context.read<AppState>();
      
      appState.createOrder(
        shippingAddress: _addressController.text,
        phone: _phoneController.text,
        paymentMethod: _selectedPaymentMethod,
        deliveryFee: 30.0, // يمكن تعديل هذه القيمة حسب المنطقة
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تأكيد طلبك بنجاح!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.of(context).popUntil((route) => route.isFirst);
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
