import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_auth/screens/otp_screen.dart';
import 'package:flutter_otp_auth/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedId = false;

  bool get isSignedIn => _isSignedId;

  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseFirestore = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _uid;

  String get uid => _uid!;

  UserModel? _userModel;

  UserModel get userModel => _userModel!;

  AuthProvider() {
    checkSign();
  }

  void checkSign() async {
    final prefs = await SharedPreferences.getInstance();
    _isSignedId = prefs.getBool('is_signedin') ?? false;
    notifyListeners();
  }

  Future<void> setSignedId() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_signedin', true);
    _isSignedId = true;
    notifyListeners();
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId),
            ),
          );
          // String smsCode = 'xxxx';
          //
          // PhoneAuthCredential credential = PhoneAuthProvider.credential(
          //   verificationId: verificationId,
          //   smsCode: smsCode,
          // );
          //
          // await _firebaseAuth.signInWithCredential(credential);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {}
  }

  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: userOtp,
    );
    final response = await _firebaseAuth.signInWithCredential(credential);
    final User? user = response.user;
    if (user != null) {
      _uid = user.uid;
      onSuccess();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection('users').doc(_uid).get();
    if (snapshot.exists) {
      print('USER EXIST');
      return true;
    } else {
      print('NEW USER');
      return false;
    }
  }

  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required File profilePick,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final value = await storeFileToStorage('profilePick/$_uid', profilePick);
      userModel.profilePick = value;
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
      userModel.uid = _firebaseAuth.currentUser!.phoneNumber!;

      _userModel = userModel;

      await _firebaseFirestore
          .collection('users')
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackbar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    final TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> saveUserDataToSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'user_model',
      jsonEncode(userModel.toMap()),
    );
  }
}
