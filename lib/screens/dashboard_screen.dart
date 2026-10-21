import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'input_screen.dart';
import 'upgrade_screen.dart';
import '../services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();

    // 1. ADD THIS PRINT STATEMENT:
    final user = FirebaseAuth.instance.currentUser;
    
    // Ensure the document exists in Firestore when the dashboard loads
    _dbService.initializeUserDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              AuthService().signOut();
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _dbService.getUserDataStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('crash: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Initializing Database...'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List items = data['items'] ?? [];
          final bool isProUser = data['isProUser'] ?? false;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isProUser ? 'Pro Account' : 'Free Account: ${items.length} / 5 items',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    //final String itemName = items[index].toString();
                    final item = items[index] as Map<String, dynamic>;
                    final String itemName = item['name'] ?? 'Unknown Item';
                    final String dateString = item['expiryDate'] ?? '';

                    // Parse the string back into a DateTime object from UI
                    final DateTime? expiryDate = dateString.isNotEmpty ? DateTime.parse(dateString) : null;

                    // Dismissible widget allows swipe-to-delete functionality with proper cleanup
                    return Dismissible(
                      key: Key(itemName),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      
                      // 1. Inject the Confirmation Gate
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: Text('Are you sure you want to remove this item?\n\n$itemName'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false), // Rejects swipe
                                  child: const Text('CANCEL'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, 
                                    foregroundColor: Colors.white
                                  ),
                                  onPressed: () => Navigator.of(context).pop(true), // Authorizes deletion
                                  child: const Text('DELETE'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      // 2. Existing Execution Block
                      onDismissed: (direction) async {
                        await NotificationService().cancelNotification(itemName.hashCode);
                        await _dbService.removeItem(itemName);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$itemName deleted')),
                          );
                        }
                      },
                      child: ListTile(
                        title: Text(itemName),
                        subtitle: Text(
                          expiryDate != null 
                               ? 'Expires on: ${expiryDate.toLocal().toString().split(' ')[0]}'
                               : 'No expiry date set',
                        ),
                      ),
                    ); 
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // 1. Client-Side Check: Immediately block UI
                    if (items.length >= 5 && !isProUser) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Limit Reached (5/5)'),
                          action: SnackBarAction(
                            label: 'UPGRADE',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const UpgradeScreen()),
                              );
                            },
                          ),
                        ),
                      );
                      return; 
                    }
                    
                    // 2. Route to the Input Screen if under the limit
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InputScreen()),
                    );
                  },
                  child: const Text('Add Item'),
                ),
              )
            ],
          );  
        },
      ),
    );
  }
}