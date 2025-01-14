import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'login_page.dart';
import 'orders_page.dart';
import 'addresses_page.dart';
import 'about_app_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: SafeArea(
            child: appState.isLoggedIn
                ? _buildLoggedInView(context, appState)
                : _buildLoggedOutView(context),
          ),
        );
      },
    );
  }

  Widget _buildLoggedInView(BuildContext context, AppState appState) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // معلومات المستخدم
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6E58A8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  appState.userEmail?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E58A8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.userEmail ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'مرحباً بك في متجر عمر',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // قائمة الخيارات
        _buildOptionTile(
          context,
          icon: Icons.location_on_outlined,
          title: 'عناويني',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddressesPage(),
              ),
            );
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.list_alt_outlined,
          title: 'طلباتي',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrdersPage(),
              ),
            );
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.support_agent_outlined,
          title: 'الدعم الفني',
          onTap: () {
            // TODO: تنفيذ صفحة الدعم الفني
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('عن التطبيق'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutAppPage(),
              ),
            );
          },
        ),
        const Divider(),
        _buildOptionTile(
          context,
          icon: Icons.info_outline,
          title: 'عن التطبيق',
          onTap: () {
            // TODO: تنفيذ صفحة عن التطبيق
          },
        ),
        const SizedBox(height: 24),
        
        // زر تسجيل الخروج
        ElevatedButton(
          onPressed: () async {
            try {
              await appState.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الخروج بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'تسجيل الخروج',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: Color(0xFF6E58A8),
            ),
            const SizedBox(height: 24),
            const Text(
              'مرحباً بك في متجر عمر',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'قم بتسجيل الدخول للوصول إلى حسابك وإدارة طلباتك وعناوينك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E58A8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text(
              'مميزات تسجيل الدخول',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildFeatureCard(
              icon: Icons.local_shipping_outlined,
              title: 'تتبع طلباتك',
              description: 'تابع حالة طلباتك وتاريخ الطلبات السابقة',
            ),
            _buildFeatureCard(
              icon: Icons.location_on_outlined,
              title: 'إدارة العناوين',
              description: 'احفظ عناوين التوصيل المفضلة لديك',
            ),
            _buildFeatureCard(
              icon: Icons.favorite_outline,
              title: 'المنتجات المفضلة',
              description: 'احفظ المنتجات المفضلة لديك للشراء لاحقاً',
            ),
            _buildFeatureCard(
              icon: Icons.local_offer_outlined,
              title: 'عروض خاصة',
              description: 'احصل على عروض وخصومات حصرية',
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                // TODO: تنفيذ صفحة الأسئلة الشائعة
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('قريباً...'),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6E58A8),
                side: const BorderSide(color: Color(0xFF6E58A8)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'الأسئلة الشائعة',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: تنفيذ صفحة اتصل بنا
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('قريباً...'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: const Text('تحتاج مساعدة؟ اتصل بنا'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6E58A8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6E58A8),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6E58A8)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
