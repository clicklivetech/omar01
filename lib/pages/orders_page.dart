import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart' as app_provider;
import '../models/order_model.dart' as order_model;
import 'order_details_page.dart';
import '../enums/order_status.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Delivered'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _OrderList(status: OrderStatus.pending),
            const _OrderList(status: OrderStatus.delivered),
            const _OrderList(status: OrderStatus.cancelled),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final OrderStatus status;

  const _OrderList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer<app_provider.AppState>(
      builder: (context, appState, child) {
        final orders = appState.getOrdersByStatus(status);
        if (orders.isEmpty) {
          return const Center(
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No orders found'),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderCard(
              id: order.id,
              status: order.status,
              totalAmount: order.totalAmount,
              createdAt: order.createdAt,
            );
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String id;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;

  const _OrderCard({
    super.key,
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(
                order: order_model.OrderModel(
                  id: id,
                  userId: context.read<app_provider.AppState>().currentUserId ?? 'guest_user',
                  status: status,
                  totalAmount: totalAmount,
                  shippingAddress: '',
                  phone: '',
                  createdAt: createdAt,
                  updatedAt: DateTime.now(),
                  items: const [],
                  paymentMethod: order_model.PaymentMethod.cashOnDelivery,
                  deliveryFee: 0,
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$id',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 8),
              Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              Text('Date: ${_formatDate(createdAt)}'),
              if (status == OrderStatus.pending)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _cancelOrder(context),
                        child: const Text('Cancel Order'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    const textColor = Colors.white;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red;
        break;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
      case OrderStatus.shipping:
        backgroundColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _capitalizeFirst(status.name),
        style: TextStyle(color: textColor),
      ),
    );
  }

  void _cancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<app_provider.AppState>().cancelOrder(id);
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
