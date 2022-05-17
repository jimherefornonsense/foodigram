import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodigram/data_center.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../database/models.dart';

class AuthService {
  final FirebaseAuth _firebaseInstance = FirebaseAuth.instance;

  Map<String, String> errorMessage = {
    "email": "",
    "password": "",
    "network": "",
  };

  // User State
  Stream<User?> authStateChanges() {
    FirebaseAuth _firebaseInstance = FirebaseAuth.instance;
    return _firebaseInstance.authStateChanges();
  }

  // Current User
  User? currentUser() {
    FirebaseAuth _firebaseInstance = FirebaseAuth.instance;
    return _firebaseInstance.currentUser;
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final user = await FirebaseAuth.instance.signInWithCredential(credential);

    Account account = Account(
      uid: user.user!.uid,
      email: user.user!.email!,
      postIdSet: [],
    );
    DataCenter().addUser(account);
  }

  // Sign Out
  Future<void> signOut() async {
    FirebaseAuth _firebaseInstance = FirebaseAuth.instance;
    return _firebaseInstance.signOut();
  }

  // Sign In With Email And Password
  Future<Map<String, String>> signIn(String email, String password) async {
    try {
      await _firebaseInstance.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (error) {
      if (error.message ==
          "An internal error has occurred. [ Unable to resolve host \"www.googleapis.com\":No address associated with hostname ]") {
        errorMessage["network"] = "No internet connection. Try again!";
      }
      switch (error.code) {
        case "invalid-email":
          log("ERROR_INVALID_EMAIL");
          errorMessage["email"] = "Invalid email";
          break;
        case "wrong-password":
          log("ERROR_WRONG_PASSWORD");
          errorMessage["password"] = "Wrong password";
          break;
        case "user-not-found":
          log("ERROR_USER_NOT_FOUND");
          errorMessage["email"] = "Email not registered. Please sign up!";
          break;
        case "user-disabled":
          log("ERROR_USER_DISABLED");
          errorMessage["email"] = "This user has been disabled";
          break;
      }
    }
    return errorMessage;
  }

  // Create User With Email And Password
  Future<Map<String, String>> signUp(String email, String password) async {
    try {
      await _firebaseInstance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) {
        if (user.user != null) {
          // Save User Information To Database
          Account account = Account(
            uid: user.user!.uid,
            email: user.user!.email!,
            postIdSet: [],
          );
          DataCenter().addUser(account);
          return null;
        } else {
          return null;
        }
      });
    } on FirebaseAuthException catch (error) {
      if (error.message ==
          "An internal error has occurred. [ Unable to resolve host \"www.googleapis.com\":No address associated with hostname ]") {
        errorMessage["network"] = "No internet connection. Try again!";

        switch (error.code) {
          case "invalid-email":
            log("ERROR_INVALID_EMAIL");
            errorMessage["email"] = "Invalid email";
            break;
          case "weak-password":
            log("ERROR_WEAK_PASSWORD");
            errorMessage["email"] =
                "Password should be at least 6 characters long";
            break;
          case "email-already-in-use":
            log("ERROR_EMAIL_ALREADY_IN_USE");
            errorMessage["email"] = "Email already in use. Please log in!";
            break;
          case "operation-not-allowed":
            log("ERROR_OPERATION_NOT_ALLOWED");
            break;
        }
      }
    }
    return errorMessage;
  }
}
