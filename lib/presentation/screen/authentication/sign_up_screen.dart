import 'package:flashi/presentation/screen/authentication/sign_in_screen.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flashi/util/helpers/classes/other/wepage_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    void _navigateHome(){
      Navigator.pop(context);
      final onboardingProvider = Provider.of<OnboardingProvider>(context,listen: false);
      onboardingProvider.completeOnboarding();
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.primary),
          onPressed: () => _navigateHome(),
        ),
        title: Text(
          "Skip",
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 15, // Slightly adjusted for better fit
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis, // Handles overflow gracefully
        ),
        centerTitle: false, // Aligns title to the left (optional)
      ),

      backgroundColor: colorScheme.background,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Icon(
                        Icons.school_rounded,
                        color: colorScheme.primary,
                        size: 60,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Create an Account",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Join us and sync your flashcard across devices.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildTextField(
                      context,
                      icon: Icons.person,
                      label: "Full Name",
                      isPassword: false,
                      controller: authProvider.usernameController,
                      isPasswordVisible: false,
                      onToggleVisibility: () {  },
                    ),
                    _buildTextField(
                      context,
                      icon: Icons.email,
                      label: "Email Address",
                      isPassword: false,
                      controller: authProvider.emailController,
                      isPasswordVisible: false,
                      onToggleVisibility: () {  },
                    ),

                    _buildTextField(
                      context,
                      icon: Icons.lock,
                      label: "Password",
                      isPassword: true,
                      controller: authProvider.passwordController,
                      isPasswordVisible: authProvider.isPasswordVisible,
                      onToggleVisibility: () {
                        authProvider.togglePasswordVisibility();
                      },
                    ),

                    _buildTextField(
                      context,
                      icon: Icons.lock_outline,
                      label: "Confirm Password",
                      isPassword: true,
                      controller: authProvider.confirmPasswordController,
                      isPasswordVisible: authProvider.isPasswordVisible,
                      onToggleVisibility: () {
                        authProvider.togglePasswordVisibility();
                      },
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Checkbox(
                          value: authProvider.isAgree,
                          onChanged: (value) {
                            authProvider.toggleAgreement();
                          },
                          activeColor: colorScheme.primary,
                          checkColor: colorScheme.onPrimary,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: "I agree to the ",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: colorScheme.onBackground,
                              ),
                              children: [
                                TextSpan(
                                  text: "Terms & Conditions",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {

                                      WebPageLauncher(
                                          'https://curib123.github.io/flashi_/terms%26condition.html')
                                          .launch();
                                    },
                                ),
                                TextSpan(
                                  text: " and ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: colorScheme.onBackground,
                                  ),
                                ),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      WebPageLauncher(
                                          'https://curib123.github.io/flashi_/privacy_policy.html')
                                          .launch();
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 13),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        // Implement sign-up logic
                        await authProvider.signUp(context);
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: GoogleFonts.poppins(
                            color: colorScheme.onBackground,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: GoogleFonts.poppins(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required IconData icon,
        required String label,
        required TextEditingController controller,
        required bool isPassword,
        required bool isPasswordVisible,
        required VoidCallback? onToggleVisibility,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        obscureText: isPasswordVisible,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: colorScheme.primary),
          labelText: label,
          labelStyle: TextStyle(color: colorScheme.primary),
          filled: true,
          fillColor: colorScheme.primary.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary),
          ),
          suffixIcon: isPassword
              ? GestureDetector(
            onTap: onToggleVisibility,
            child: Icon(!isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: colorScheme.primary),
          )
              : null,
        ),
      ),
    );
  }
}
