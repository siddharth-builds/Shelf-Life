import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:know_expiry/services/notification_service.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  // Reference to the specific user's document
  DocumentReference get _userDoc => FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  // Initialize the document if it doesn't exist
  Future<void> initializeUserDocument() async {
    final snapshot = await _userDoc.get();
    if (!snapshot.exists) {
      await _userDoc.set({
        'isProUser': false,
        'items': [],
      });
    }
  }

  // Stream the document in real-time to the UI
  Stream<DocumentSnapshot> getUserDataStream() {
    if (FirebaseAuth.instance.currentUser == null){
      return const Stream.empty(); // Return an empty stream if no user is logged in
    }
    return _userDoc.snapshots();
  }

  // Attempt to add an item
  Future<void> addItem(String itemName, DateTime expiryDate) async {
    try {
      await _userDoc.set({
        'items': FieldValue.arrayUnion([
          {
            'name': itemName,
            'expiryDate': expiryDate.toIso8601String(),
          }
        ])
      }, SetOptions(merge: true)); // <--- Crucial for preventing overwrites

      // ADD THIS: Generate a unique ID from the item name
      final int notificationId = itemName.hashCode;

      // ADD THIS: Schedule the real notification
      await NotificationService().scheduleExpiryNotification(
        id: notificationId,
        title: 'Item Expiring Today',
        body: '$itemName has reached its expiration date.',
        scheduledDate: expiryDate,
      );

    } catch (e, stackTrace) {
      debugPrint("CRITICAL SAVE ERROR: $e");
      debugPrint("STACK TRACE: $stackTrace");
      rethrow; // Pass the error back to the UI Snackbar
    }
  }

  // Execute the Pro Upgrade
  Future<void> upgradeToPro() async {
    try {
      await _userDoc.update({'isProUser': true});
    } catch (e) {
      debugPrint("Upgrade failed: $e");
      rethrow;
    }
  }
  
  // Remove an item from the Firestore array
  Future<void> removeItem(String itemName) async {
    try {
      // 1. Fetch the latest document to see the exact maps
      final snapshot = await _userDoc.get();
      if (!snapshot.exists) return;
      
      final List<dynamic> currentItems = snapshot.get('items') ?? [];
      
      // 2. Find the exact map that matches the item name
      final exactItemToRemove = currentItems.firstWhere(
        (item) => item['name'] == itemName, 
        orElse: () => null
      );
      
      // 3. Tell Firestore to remove that exact map object
      if (exactItemToRemove != null) {
        await _userDoc.update({
          'items': FieldValue.arrayRemove([exactItemToRemove])
        });
      }

      // 4. Cancel the scheduled notification for this item
      // Generate the exact same ID you used to create it
      final int notificationId = itemName.hashCode;

       // Tell the OS to delete this specific timer
      await NotificationService().cancelNotification(notificationId);
      
    } catch (e) {
      debugPrint("Firestore delete rejected: $e");
      rethrow;
    }
  }
}