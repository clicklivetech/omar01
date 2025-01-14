import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عن التطبيق'),
        backgroundColor: const Color(0xFF6E58A8),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/iconOmar-512x512.png',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'عمر ماركت',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E58A8),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تسوق بذكاء، وفر أكثر',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'من نحن',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E58A8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'عمر ماركت هو تطبيق تسوق إلكتروني يهدف إلى توفير تجربة تسوق سهلة وممتعة لعملائنا. نحن نقدم مجموعة واسعة من المنتجات عالية الجودة بأسعار تنافسية.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'مميزاتنا',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E58A8),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.local_shipping_outlined,
              'توصيل سريع',
              'نوفر خدمة توصيل سريعة وموثوقة لجميع مناطق المدينة',
            ),
            _buildFeatureItem(
              Icons.security_outlined,
              'جودة مضمونة',
              'نضمن جودة جميع منتجاتنا ونوفر ضمان استرجاع',
            ),
            _buildFeatureItem(
              Icons.support_agent_outlined,
              'دعم متواصل',
              'فريق خدمة العملاء متاح دائماً للرد على استفساراتكم',
            ),
            _buildFeatureItem(
              Icons.local_offer_outlined,
              'عروض مستمرة',
              'نقدم عروضاً وخصومات مستمرة على مدار العام',
            ),
            const SizedBox(height: 32),
            const Text(
              'تواصل معنا',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E58A8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'نسعد بتواصلكم معنا عبر:\nالهاتف: 0123456789\nالبريد الإلكتروني: info@omarmarket.com',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: const Color(0xFF6E58A8),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
