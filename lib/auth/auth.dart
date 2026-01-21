import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


final _googleSignIn = GoogleSignIn(
      clientId: "448892257654-s599rpt6hcqjl5fbv51mq7iokdinrssd.apps.googleusercontent.com",
    );

// Sign Up
Future<User?> signUp(String email, String password) async {
  try {
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } catch (e) {
    // Handle errors (weak password, email in use, etc.)
    throw e;
  }
}

// Sign In
Future<User?> signIn(String email, String password) async {
  try {
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } catch (e) {
    throw e;
  }
}

// Sign In with Google
Future<User?> signInWithGoogle() async {
  try {

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;
  } catch (e) {
    throw e;
  }
}

// Sign Out
// Future<void> signOut() async {
//   final googleSignIn = GoogleSignIn();
//   await googleSignIn.disconnect();
//   await googleSignIn.signOut();
//   await FirebaseAuth.instance.signOut();
// }

Future<void> signOut() async {
   try {
    // Only disconnect if signed in
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.disconnect(); // revokes access
    }

    await _googleSignIn.signOut(); // normal sign out
    await FirebaseAuth.instance.signOut(); // Firebase logout
  } catch (e) {
    print('Sign out error: $e'); // prevents crash
  }
} 
