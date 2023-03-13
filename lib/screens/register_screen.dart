import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_auth/provider/auth_provider.dart';
import 'package:flutter_otp_auth/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController();

  Country selectedCountry = Country(
    phoneCode: '996',
    countryCode: '312',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Bishkek",
    example: 'Bishkek',
    displayName: 'Display',
    displayNameNoCountryCode: 'KG',
    e164Key: '',
  );

  @override
  Widget build(BuildContext context) {
    _phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneController.text.length),
    );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.shade50,
                ),
                child: Image.asset('assets/landing.jpg'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add your phone number. We\'ll send you a verification code',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => showCountryPicker(
                        context: context,
                        exclude: ['KN', 'MF'],
                        favorite: ['SE'],
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          print('Select country: ${country.displayName}');
                          setState(() {
                            selectedCountry = country;
                          });
                        },
                        countryListTheme: CountryListThemeData(
                          bottomSheetHeight:
                              MediaQuery.of(context).size.height / 2,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40.0),
                            topRight: Radius.circular(40.0),
                          ),
                          inputDecoration: InputDecoration(
                            labelText: 'Search',
                            hintText: 'Start typing to search',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF8C98A8).withOpacity(0.2),
                              ),
                            ),
                          ),
                          searchTextStyle: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      child: Text(
                        '${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: sendPhone,
                  text: 'Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendPhone() async {
    final authProvider = context.read<AuthProvider>();
    final countryCode = '+${selectedCountry.phoneCode}';
    final phoneNumber = _phoneController.text.trim();
    print(countryCode + phoneNumber);
    authProvider.signInWithPhone(context, countryCode + phoneNumber);
  }
}
