import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_otp_auth/models/user_model.dart';
import 'package:flutter_otp_auth/provider/auth_provider.dart';
import 'package:flutter_otp_auth/screens/home_screen.dart';
import 'package:flutter_otp_auth/utils/utils.dart';
import 'package:provider/provider.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({Key? key}) : super(key: key);

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  File? image;

  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final isLoading = authProvider.isLoading;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
                child: Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: selectImage,
                        child: image == null
                            ? const CircleAvatar(
                                radius: 50.0,
                                backgroundColor: Colors.purple,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 50,
                                ),
                              )
                            : CircleAvatar(
                                backgroundImage: FileImage(image!),
                                radius: 50,
                              ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        child: Column(
                          children: [
                            _textField(
                              controller: _nameController,
                              hintText: 'John Smith',
                              icon: Icons.account_circle,
                              maxLines: 1,
                              inputType: TextInputType.text,
                            ),
                            _textField(
                              controller: _emailController,
                              hintText: 'abc@example.com',
                              icon: Icons.email,
                              maxLines: 1,
                              inputType: TextInputType.emailAddress,
                            ),
                            _textField(
                              controller: _bioController,
                              hintText: 'Enter your bio here',
                              icon: Icons.edit,
                              maxLines: 2,
                              inputType: TextInputType.text,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: storeData,
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _textField({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Colors.purple,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(icon),
        ),
      ),
    );
  }

  void storeData() async {
    final authProvider = context.read<AuthProvider>();
    UserModel userModel = UserModel(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      profilePick: '',
      createdAt: '',
      phoneNumber: '',
      uid: '',
    );

    if (image != null) {
      authProvider.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        profilePick: image!,
        onSuccess: () {
          authProvider.saveUserDataToSharedPref().then(
                (value) => authProvider.setSignedId().then(
                      (value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false),
                    ),
              );
        },
      );
    } else {
      showSnackbar(
        context,
        'Please upload your profile photo',
      );
    }
  }
}
