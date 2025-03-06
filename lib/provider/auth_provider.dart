
import 'package:flashi/presentation/screen/authentication/sign_in_screen.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/auth_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/loading_dialog.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/show_merge_flashcard_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final supabase = Supabase.instance.client;
  final String tableName = "flashcards";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  bool isPasswordVisible = false;
  bool isAgree = false;
  String username = "Guest Account";
  String email = "AI-Powered Flashcard Generator";
  String user_id = "";
  int user_credits = 0;

  String DefaultUsername = "Guest Account";
  String DefaultEmail = "AI-Powered Flashcard Generator";

  AuthProvider(){
   loadUserData(); // Load user data from secure storage
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleAgreement() {
    isAgree = !isAgree;
    notifyListeners();
  }

  void updateUsername(String newUsername) {
    username = newUsername;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }
 void updateUserId(String newUserId) {
    user_id = newUserId;
    notifyListeners();
  }

  void updateUserCredits(int newUserCredits) {
    user_credits = newUserCredits;
    notifyListeners();
  }

  /// Check for internet connection before making network requests
  Future<bool> hasInternet() async {
    return await InternetConnection().hasInternetAccess;
  }

  Future<void> signIn(BuildContext context,QuizProvider quizProvider, AiCreditProvider aiCreditProvider) async {
    if (!await hasInternet()) {
      showAuthDialog(context, "Error", "No internet connection. Please try again.");
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showAuthDialog(context, "Error", "Please enter email and password");
      return;
    }

    showLoadingDialog(context, text: "Please wait ...");
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Save session to the device
        await supabase.auth.refreshSession();

        String fetchedUsername = response.user!.userMetadata?['username'] ?? "User";
        int FetchCredits = await fetchUserCredits(user_id) ?? 0;
        final fetchedUserId = response.user!.id;
        updateUsername(fetchedUsername);
        updateUserId(fetchedUserId);
        updateUserCredits(FetchCredits);
        aiCreditProvider.updateCredits(user_credits);
        updateEmail(response.user!.email ?? "AI-Powered Flashcard Generator");

        print(" user credits : ${user_credits}");

        // Securely store email and username
        await secureStorage.write(key: "email", value: email);
        await secureStorage.write(key: "username", value: fetchedUsername);
        await secureStorage.write(key: "user_id", value: fetchedUserId);


        showMergeFlashcardDialog(
          context,
          onMerge: ()  {
            if (context.mounted) {
              quizProvider.updateQuizSets(fetchFlashcards(user_id), merge: true);
              saveFlashcards(user_id, quizProvider.quizSets);
              saveUserCredits(user_id, user_credits);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);

            }
          },
          onDiscard: ()  {
            if (context.mounted) {
              quizProvider.updateQuizSets(fetchFlashcards(user_id), merge: false);
              saveFlashcards(user_id, quizProvider.quizSets);
              saveUserCredits(user_id, user_credits);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            }
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Successfully logged in, $fetchedUsername",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        if (!context.mounted) return;
        Navigator.pop(context);
        showAuthDialog(context, "Error", "Invalid credentials");
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      showAuthDialog(context, "Error", "Sign in failed: ${e.toString()}");
    }

  }

  Future<void> signUp(BuildContext context) async {
    if (!isAgree) {
      showAuthDialog(context, "Error", "You must agree to the Terms & Conditions and Privacy Policy.");
      return;
    }

    if (!await hasInternet()) {
      showAuthDialog(context, "Error", "No internet connection. Please try again.");
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final username = usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || username.isEmpty) {
      showAuthDialog(context, "Error", "Please fill all fields");
      return;
    }

    // Email validation check
    if (!email.contains("@") || !email.contains(".")) {
      showAuthDialog(context, "Error", "Please enter a valid email address");
      return;
    }

    if (password.length < 6) {
      showAuthDialog(context, "Error", "Password must be at least 6 characters long");
      return;
    }

    if (password != confirmPassword) {
      showAuthDialog(context, "Error", "Passwords do not match");
      return;
    }

    showLoadingDialog(context, text: "Checking email availability...");
    try {
      // Try signing up the user
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      Navigator.pop(context); // Close loading dialog

      if (response.user != null) {

        showAuthDialog(context, "Success", "Account created for ${response.user!.email}");
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ),
          );
        });
      } else {
        showAuthDialog(context, "Error", "Account creation failed");
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      String errorMessage = "Sign up failed: ${e.toString()}";

      if (e.toString().contains("User already registered")) {
        errorMessage = "Email is already in use. Please use a different email.";
      }

      showAuthDialog(context, "Error", errorMessage);
    }
  }

  Future<void> signOut(BuildContext context,QuizProvider quizProvider) async {
    if (!await hasInternet()) {
      showAuthDialog(context, "Error", "No internet connection. Please try again.");
      return;
    }

    try {
      await supabase.auth.signOut();
      await secureStorage.delete(key: "email");   // Remove email from secure storage
      await secureStorage.delete(key: "username"); // Remove username from secure storage

      updateUsername(DefaultUsername);
      updateEmail(DefaultEmail);
      showAuthDialog(context, "Success", "Signed out successfully");
    } catch (e) {
      showAuthDialog(context, "Error", "Sign out failed: ${e.toString()}");
    }
  }

  /// Load user data from secure storage
  Future<void> loadUserData() async {
    email = await secureStorage.read(key: "email") ?? "AI-Powered Flashcard Generator";
    username = await secureStorage.read(key: "username") ?? "Guest Account";
    user_id = await secureStorage.read(key: "user_id") ?? "";

    int FetchCredits = await fetchUserCredits(user_id) ?? 0;
    updateUserCredits(FetchCredits);
    notifyListeners();
  }

  Future<void> resetPassword(BuildContext context) async {
    if (!await hasInternet()) {
      showAuthDialog(context, "Error", "No internet connection. Please try again.");
      return;
    }

    final email = emailController.text.trim();

    if (email.isEmpty) {
      showAuthDialog(context, "Error", "Please enter your email address");
      return;
    }

    showLoadingDialog(context, text: "Sending reset email...");

    try {
      await supabase.auth.resetPasswordForEmail(email);
      Navigator.pop(context); // Close loading dialog

      showAuthDialog(context, "Success",
          "A password reset email has been sent to $email. Check your inbox.");
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      showAuthDialog(context, "Error", "Failed to send reset email: ${e.toString()}");
    }
  }

  Future<void> saveFlashcards(String userId, List<Map<String, dynamic>> flashcards) async {
    try {
      if (userId.isEmpty) {
        throw Exception("User is not signed in.");
      }

      // Convert DateTime fields to String (ISO8601 format) and ensure correct types
      List<Map<String, dynamic>> sanitizedFlashcards = flashcards.map<Map<String, dynamic>>((flashcard) {
        return {
          for (var entry in flashcard.entries)
            if (entry.value is DateTime)
              entry.key: (entry.value as DateTime).toIso8601String()
            else if (entry.key == "cards" && entry.value is List)
              entry.key: (entry.value as List).map<Map<String, dynamic>>((card) {
                final cardMap = card as Map<dynamic, dynamic>;
                return {
                  for (var cardEntry in cardMap.entries)
                    if (cardEntry.value is DateTime)
                      cardEntry.key: (cardEntry.value as DateTime).toIso8601String()
                    else
                      cardEntry.key: cardEntry.value
                };
              }).toList()
            else
              entry.key: entry.value
        };
      }).toList();

      // Check if user already exists
      final existingData = await supabase
          .from('flashcards')
          .select('data')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingData != null) {
        // Update existing flashcards
        await supabase.from('flashcards').update({
          'data': sanitizedFlashcards,
        }).eq('user_id', userId);
      } else {
        // Insert new entry
        await supabase.from('flashcards').insert({
          'user_id': userId,
          'data': sanitizedFlashcards,
        });
      }

      print("Flashcards saved successfully!");
    } catch (e) {
      throw Exception("Error saving flashcards: $e");
    }
  }

  Future<void> saveUserCredits(String userId, int userCredits) async {
    try {
      if (userId.isEmpty) {
        throw Exception("User is not signed in.");
      }

      // Update or insert user credits separately
      final existingUser = await supabase
          .from('flashcards')
          .select('user_credits')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingUser != null) {
        await supabase.from('flashcards').update({
          'user_credits': userCredits,
        }).eq('user_id', userId);
      } else {
        await supabase.from('flashcards').insert({
          'user_id': userId,
          'user_credits': userCredits,
        });
      }

      print("User credits saved successfully!");
    } catch (e) {
      throw Exception("Error saving user credits: $e");
    }
  }

  Future<int?> fetchUserCredits(String userId) async {
    try {
      final response = await supabase
          .from(tableName)
          .select('user_credits')
          .eq('user_id', userId)
          .single(); // Fetch exactly one row

      return response['user_credits'] as int?;
    } catch (e) {
      print("Error fetching user credits: $e");
      return null;
    }
  }



  Future<List<Map<String, dynamic>>> fetchFlashcards(String userId) async {
    try {
      final response = await supabase
          .from(tableName)
          .select('data')
          .eq('user_id', userId)
          .maybeSingle(); // Fetches a single entry instead of a list

      if (response == null || response['data'] == null) return []; // No data found

      // Ensure proper type conversion
      final List<Map<String, dynamic>> flashcards =
      (response['data'] as List).map<Map<String, dynamic>>((flashcard) {
        final cardMap = flashcard as Map<String, dynamic>;

        return {
          for (var entry in cardMap.entries)
            if (entry.key == "timestamp" && entry.value is String)
              entry.key: DateTime.parse(entry.value) // Convert back to DateTime
            else if (entry.key == "cards" && entry.value is List)
              entry.key: (entry.value as List).map<Map<String, dynamic>>((card) {
                final innerCardMap = card as Map<String, dynamic>;
                return {
                  for (var cardEntry in innerCardMap.entries)
                    if (cardEntry.key == "timestamp" && cardEntry.value is String)
                      cardEntry.key: DateTime.parse(cardEntry.value) // Convert back
                    else
                      cardEntry.key: cardEntry.value
                };
              }).toList()
            else
              entry.key: entry.value
        };
      }).toList();

      return flashcards;
    } catch (e) {
      throw Exception("Error fetching flashcards: $e");
    }
  }


}
