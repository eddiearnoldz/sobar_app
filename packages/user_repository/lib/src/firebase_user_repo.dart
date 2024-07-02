import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/user_repository.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final userCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<MyUser?> get user {
    return _firebaseAuth.authStateChanges().flatMap((firebaseUser) async* {
      if (firebaseUser == null) {
        yield MyUser.empty;
      } else {
        yield await userCollection.doc(firebaseUser.uid).get().then((value) => MyUser.fromEntity(MyUserEntity.fromJson(value.data()!)));
      }
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Handle user not found error
        log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        // Handle wrong password error
        log('Your password does not match the account');
      } else {
        // Handle other errors
        log('Error signing in: ${e.message}');
      }
      // Rethrow the exception after handling
      rethrow;
    } catch (e) {
      // Handle other exceptions
      log('Error signing in: $e');
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(email: myUser.email, password: password);
      myUser.userId = user.user!.uid;
      return myUser; // Return MyUser upon successful signup
    } on FirebaseAuthException catch (e) {
      String errorMessage = getFirebaseErrorMessage(e); // Get error message using helper function
      log(errorMessage); // Log the error message
      throw FirebaseAuthException(message: errorMessage, code: e.code); // Throw FirebaseAuthException with modified message
    } catch (e) {
      // Handle other exceptions
      log('Error signing up: $e');
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await userCollection.doc(myUser.userId).set(myUser.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

    String getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'User account has been disabled';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email address is already in use';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Weak password, must be at least 6 characters';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
