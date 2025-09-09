import 'package:flutter/material.dart';
import 'shop_card.dart';

class ShopDetailPage extends StatelessWidget {
  final Shop shop;
  const ShopDetailPage({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          shop.name,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[900],
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(shop.logoAsset),
                  backgroundColor: Colors.grey[100],
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    Text(
                      '${shop.category} · ${shop.city}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Avg UPI/day: ₹${shop.avgUpi}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              'Ticket: ₹${shop.ticket}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              'Est Return: ${shop.estReturn}x',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              'Raised: ₹${shop.raised}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              'Target: ₹${shop.target}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 22),
            LinearProgressIndicator(
              value: (shop.raised / shop.target).clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
            ),
            const SizedBox(height: 22),
            Text(
              'More details coming soon...',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
