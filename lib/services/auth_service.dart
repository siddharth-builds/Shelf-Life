import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(authProvider);
      } else {
        // 1. Initialize the v7+ singleton with your Web Client ID
        await GoogleSignIn.instance.initialize(
          serverClientId: '1098495282685-2rj28oj1m598l39u8fcumrl6bcnd71s1.apps.googleusercontent.com',
        );
        
        // 2. Trigger the native flow using authenticate() (replaces signIn)
       final googleUser = await GoogleSignIn.instance.authenticate();          
        // 3. Access authentication synchronously (removed 'await')
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        
        // 4. Request authorization separately to get the accessToken
        final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);

        // 5. Create Firebase Credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: clientAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        //return await _auth.signInWithCredential(credential);
        final UserCredential userCred = await _auth.signInWithCredential(credential);
        // Bootstrap the user document if it doesn't exist
        if (userCred.user != null) {
          final userRef = FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid);
          final docSnap = await userRef.get();
          if (!docSnap.exists) {
            await userRef.set({
              'isProUser': false,
              'items': [],
            });
          }
        }
        return userCred;
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut(); // Ensure singleton is used here as well
    }
  }
}