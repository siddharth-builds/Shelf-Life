import 'package:flutter/material.dart';
import '../services/database_service.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  bool _isProcessing = false;

  Future<void> _processMockPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate a 2-second network call to a payment gateway
    await Future.delayed(const Duration(seconds: 2)); 
    
    try {
      await DatabaseService().upgradeToPro();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful! Welcome to Pro.')),
        );
        Navigator.pop(context); // Return to Dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction Failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to Pro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                'Unlock Unlimited Items',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Remove the 5-item limit and manage your entire inventory forever.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isProcessing ? null : _processMockPayment,
                  child: _isProcessing 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Pay \$4.99 (Mock)'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}