import 'dart:convert';
import 'package:client/constants/app_colors.dart';
import 'package:client/constants/app_styles.dart';
import 'package:client/helpers/asset_images.dart';
import 'package:client/helpers/helper_function.dart';
import 'package:client/screens/auth/signin_screen.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/widgets/button_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKeyEmail = GlobalKey<FormState>();
  final formKeyPassword = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _checkboxValue = false;
  bool _nextInput = false;
  bool _isLoading = false;
  bool _showPassword = true;

  register() async {
    if (_nextInput) {
      if (formKeyPassword.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });

        await Future.delayed(const Duration(seconds: 1));

        final reqBody = {
          "email": _emailController.text,
          "password": _passwordController.text,
        };
        
        try {
          final response = await AuthService.registerUser(reqBody);

          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == true) {
            _emailController.text = '';
            _passwordController.text = '';

            setState(() {
              _isLoading = false;
            });
            // ignore: use_build_context_synchronously
            showSnackBar(
                context, AppColors.greenColor, 'Register successfully');
          } else {
            setState(() {
              _isLoading = false;
            });
            // ignore: use_build_context_synchronously
            showSnackBar(context, AppColors.redColor, 'Register failure');
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          // ignore: use_build_context_synchronously
          showSnackBar(context, AppColors.redColor, 'Register failure');
        }
      }
    } else {
      if (formKeyEmail.currentState!.validate()) {
        setState(() {
          _nextInput = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset(AssetImages.logo, scale: 1.2),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        )
                      : const Text(
                          'Sign up for free',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  const SizedBox(height: 40),
                  !_nextInput
                      ? Form(
                          key: formKeyEmail,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.only(left: 12, bottom: 4),
                                child: const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                                decoration: AppStyles.inputDecoration(
                                  'Email',
                                  Icons.email,
                                ),
                                validator: (value) {
                                  return RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                  ).hasMatch(value!)
                                      ? null
                                      : "Please enter a valid email";
                                },
                              ),
                            ],
                          ),
                        )
                      : Form(
                          key: formKeyPassword,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.only(left: 12, bottom: 4),
                                child: const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                                obscureText: _showPassword,
                                validator: (value) {
                                  if (value!.length < 6) {
                                    return "Password must be at least 6 characters";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: AppStyles.inputDecoration(
                                  'Password',
                                  Icons.key_sharp,
                                ).copyWith(
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                      child: _showPassword
                                          ? const Icon(
                                              Icons.visibility_off,
                                              color: AppColors.primaryColor,
                                            )
                                          : const Icon(
                                              Icons.visibility,
                                              color: AppColors.primaryColor,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                                value: _checkboxValue,
                                activeColor: AppColors.primaryColor,
                                side: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _checkboxValue = !_checkboxValue;
                                  });
                                }),
                            const Text('Remember me'),
                          ],
                        ),
                        _nextInput
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _nextInput = false;
                                  });
                                },
                                child: const Text(
                                  'Go back',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ButtonWidget(
                      func: register,
                      text: !_nextInput ? 'Next' : 'Sign up',
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      text: "Already have an Account? ",
                      style: const TextStyle(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Sign in",
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              nextScreen(context, const SigninScreen());
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
