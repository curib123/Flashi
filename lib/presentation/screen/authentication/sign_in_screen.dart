import 'package:flashi/presentation/screen/authentication/sign_up_screen.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/chatbot_provider.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flashi/provider/onboarding_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatelessWidget {


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
          title:
              GestureDetector(
                onTap: () => _navigateHome(),
                child: Text(
                  "Sign in later",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 15, // Slightly adjusted for better fit
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Handles overflow gracefully

                          ),
              ),
          centerTitle: false, // Aligns title to the left (optional)
        ),

      backgroundColor: colorScheme.background,
      body: Consumer6<AuthProvider,QuizProvider,AiCreditProvider,NotesProvider,ChatBotProvider,TokenProvider>(
        builder: (context, authProvider,quizProvider,aiCreditProvider, notesProvider,chatBotProvider,tokenProvider,child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.school_rounded, color: colorScheme.primary, size: 60),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Welcome Back!",
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Sign in to sync your flashcard across devices.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 30),
                  _buildTextField(
                    context,
                    icon: Icons.email,
                    label: "Email Address",
                    controller: authProvider.emailController,
                    isPassword: false,
                    isPasswordVisible: false,
                    onToggleVisibility: () {  },
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    context,
                    icon: Icons.lock,
                    label: "Password",
                    controller: authProvider.passwordController,
                    isPassword:  true,
                    onToggleVisibility: authProvider.togglePasswordVisibility,
                    isPasswordVisible: authProvider.isPasswordVisible,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 13),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      await authProvider.signIn(context, quizProvider,aiCreditProvider,notesProvider,chatBotProvider,tokenProvider);
                    },
                    child: Text("Sign In", style: GoogleFonts.poppins(fontSize: 18, color: colorScheme.onPrimary)),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: GoogleFonts.poppins(color: colorScheme.onBackground)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                        },
                        child: Text("Sign Up", style: GoogleFonts.poppins(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // GestureDetector(
                  //   onTap: () {
                  //
                  //     showEmailResetInputDialog(context, authProvider);
                  //   },
                  //   child: Text("Forgot Password?", style: GoogleFonts.poppins(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                  // ),
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

    return TextField(
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
    );
  }
}
