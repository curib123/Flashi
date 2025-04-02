
import 'package:flashi/presentation/screen/authentication/sign_in_screen.dart';
import 'package:flashi/provider/ai_credits_provider.dart';
import 'package:flashi/provider/chatbot_provider.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/token_provider.dart';
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
  String email = "Instant Quiz Maker";
  String user_id = "";

  String DefaultUsername = "Guest Account";
  String DefaultEmail = "Instant Quiz Maker";

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



  /// Check for internet connection before making network requests
  Future<bool> hasInternet() async {
    return await InternetConnection().hasInternetAccess;
  }

  Future<void> signIn(BuildContext context,QuizProvider quizProvider, AiCreditProvider aiCreditProvider,NotesProvider notesProvider,ChatBotProvider chatBotProvider, TokenProvider tokenProvider,AuthProvider authProvider) async {
    if (!await hasInternet()) {
      showAuthDialog(context,type: "error", "Error", "No internet connection. Please try again.");
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();



    if (email.isEmpty || password.isEmpty) {
      showAuthDialog(context,type: "error", "Error", "Please enter email and password");
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
        final fetchedUserId = response.user!.id ?? "";;
        updateUsername(fetchedUsername);
        updateUserId(fetchedUserId);
        updateEmail(response.user!.email ?? "Instant Quiz Maker");


        // Securely store email and username
        await secureStorage.write(key: "email", value: email);
        await secureStorage.write(key: "username", value: fetchedUsername);
        await secureStorage.write(key: "user_id", value: fetchedUserId);

        int FetchCredits = await fetchUserCredits(user_id) ?? 0;

        showMergeFlashcardDialog(
          context,
          onMerge: ()  async {
            if (context.mounted) {
              aiCreditProvider.updateCredits(FetchCredits);
              await tokenProvider.insertUserTokenBalanceIfEmpty(user_id);
              await quizProvider.updateQuizSets(fetchFlashcards(user_id), merge: true);
              await tokenProvider.fetchTokens(user_id);
              await  tokenProvider.fetchPayoutDate();
              await tokenProvider.updateIsReviewing(user_id);
              notesProvider.updateNotes(await fetchNotes(user_id),merge: true);
              chatBotProvider.updateMessages(await fetchChatBotMessages(user_id));

              showLoadingDialog(context, text: "processing...");
             Future.delayed(Duration(seconds: 3),(){
               Navigator.pop(context);
               Navigator.pop(context);
               Navigator.pop(context);
               Navigator.pop(context);

             });

            }
          },
          onDiscard: ()  async {
            if (context.mounted) {
           await aiCreditProvider.updateCredits(FetchCredits);
           await tokenProvider.insertUserTokenBalanceIfEmpty(user_id);
           await quizProvider.updateQuizSets(fetchFlashcards(user_id), merge: false);
           await tokenProvider.fetchTokens(user_id);
           await  tokenProvider.fetchPayoutDate();
           await tokenProvider.updateIsReviewing(user_id);
           notesProvider.updateNotes(await fetchNotes(user_id),merge: false);
           chatBotProvider.updateMessages(await fetchChatBotMessages(user_id));


           showLoadingDialog(context, text: "processing...");
           Future.delayed(Duration(seconds: 3),(){
             Navigator.pop(context);
             Navigator.pop(context);
             Navigator.pop(context);
             Navigator.pop(context);

           });
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
        showAuthDialog(context,type: "error", "Error", "Invalid credentials");
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      showAuthDialog(context,type: "error", "Error", "Sign in failed: ${e.toString()}");
    }

  }

  Future<void> signUp(BuildContext context) async {
    if (!isAgree) {
      showAuthDialog(context,type: "error", "Error", "You must agree to the Terms & Conditions and Privacy Policy.");
      return;
    }

    if (!await hasInternet()) {
      showAuthDialog(context,type: "error", "Error", "No internet connection. Please try again.");
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final username = usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || username.isEmpty) {
      showAuthDialog(context,type: "error", "Error", "Please fill all fields");
      return;
    }

    // Email validation check
    if (!email.contains("@") || !email.contains(".")) {
      showAuthDialog(context,type: "error", "Error", "Please enter a valid email address");
      return;
    }

    if (password.length < 6) {
      showAuthDialog(context,type: "error", "Error", "Password must be at least 6 characters long");
      return;
    }

    if (password != confirmPassword) {
      showAuthDialog(context,type: "error", "Error", "Passwords do not match");
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

        showAuthDialog(context,type: "success", "Success", "Account created for ${response.user!.email}");
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ),
          );
        });
      } else {
        showAuthDialog(context,type: "error", "Error", "Account creation failed");
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

  Future<void> signOut(BuildContext context,QuizProvider quizProvider,AiCreditProvider aiCreditProvider,NotesProvider notesProvider,ChatBotProvider chatBotProvider) async {
    if (!await hasInternet()) {
      showAuthDialog(context,type: "error", "Error", "No internet connection. Please try again.");
      return;
    }

    try {
      await supabase.auth.signOut();
      await secureStorage.delete(key: "email");   // Remove email from secure storage
      await secureStorage.delete(key: "username"); // Remove username from secure storage
      await secureStorage.delete(key: "user_id"); // Remove userid from secure storage

      updateUsername(DefaultUsername);
      updateEmail(DefaultEmail);
      updateUserId("");

      aiCreditProvider.updateCredits(0);
      notesProvider.updateNotes([], merge: false);
      chatBotProvider.updateMessages([]);
      quizProvider.updateSetToEmpty();
      showAuthDialog(context,type: "success", "Success", "Signed out successfully");
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInScreen(),
          ),
        );
      });

    } catch (e) {
      showAuthDialog(context,type: "error", "Error", "Sign out failed: ${e.toString()}");
    }
  }

  /// Load user data from secure storage
  Future<void> loadUserData() async {

    email = await secureStorage.read(key: "email") ?? "Instant Quiz Maker";
    username = await secureStorage.read(key: "username") ?? "Guest Account";
    user_id = await secureStorage.read(key: "user_id") ?? "";
    notifyListeners();
  }

  Future<void> resetPassword(BuildContext context) async {
    if (!await hasInternet()) {
      showAuthDialog(context,type: "error", "Error", "No internet connection. Please try again.");
      return;
    }

    final email = emailController.text.trim();

    if (email.isEmpty) {
      showAuthDialog(context,type: "error", "Error", "Please enter your email address");
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
      showAuthDialog(context,type: "error", "Error", "Failed to send reset email: ${e.toString()}");
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


// Function to save notes to Supabase
  Future<void> saveNotes(String userId, List<Map<String, dynamic>> _notes) async {
    try {
      if (userId.isEmpty) {
        throw Exception("User ID is required.");
      }

      // Convert DateTime fields to String format for database storage
      List<Map<String, dynamic>> sanitizedNotes = _notes.map((note) {
        return {
          for (var entry in note.entries)
            if (entry.value is DateTime)
              entry.key: (entry.value as DateTime).toIso8601String()
            else
              entry.key: entry.value
        };
      }).toList();

      // Check if the user already has notes saved
      final existingData = await supabase
          .from('notes')
          .select('data')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingData != null) {
        // Update existing notes
        await supabase.from('notes').update({
          'data': sanitizedNotes,
        }).eq('user_id', userId);
      } else {
        // Insert new notes entry
        await supabase.from('notes').insert({
          'user_id': userId,
          'data': sanitizedNotes,
        });
      }

      print("Notes saved successfully!");
    } catch (e) {
      throw Exception("Failed to save notes: $e");
    }
  }

  // Function to save messages to Supabase
  Future<void> saveChatBotMessages(String userId, List<Map<String, String>> _messages) async {
    try {
      if (userId.isEmpty) {
        throw Exception("User ID is required.");
      }

      // Check if the user already has messages saved
      final existingData = await supabase
          .from('chatbotmessages')
          .select('data')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingData != null) {
        // Update existing messages
        await supabase.from('chatbotmessages').update({
          'data': _messages,
        }).eq('user_id', userId);
      } else {
        // Insert new messages entry
        await supabase.from('chatbotmessages').insert({
          'user_id': userId,
          'data': _messages,
        });
      }

      print("Messages saved successfully!");
    } catch (e) {
      throw Exception("Failed to save messages: $e");
    }
  }

  // Function to fetch messages from Supabase
  Future<List<Map<String, String>>> fetchChatBotMessages(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception("User ID is required.");
      }

      // Fetch messages from Supabase
      final response = await supabase
          .from('chatbotmessages')
          .select('data')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['data'] is List) {
        // Convert fetched JSON data to List<Map<String, String>>
        List<Map<String, String>> messages = List<Map<String, String>>.from(
          (response['data'] as List).map((item) =>
          Map<String, String>.from(item as Map<String, dynamic>)),
        );

        return messages;
      } else {
        return []; // Return an empty list if no messages found
      }
    } catch (e) {
      throw Exception("Failed to fetch messages: $e");
    }
  }

  // Function to fetch notes from Supabase
  Future<List<Map<String, dynamic>>> fetchNotes(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception("User ID is required.");
      }

      final response = await supabase
          .from('notes')
          .select('data')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null || response['data'] == null) {
        return []; // Return an empty list if no notes found
      }

      // Convert stored DateTime strings back to DateTime objects if needed
      List<Map<String, dynamic>> fetchedNotes =
      List<Map<String, dynamic>>.from(response['data']).map((note) {
        return {
          for (var entry in note.entries)
            entry.key: (entry.value is String && DateTime.tryParse(entry.value) != null)
                ? DateTime.parse(entry.value)
                : entry.value
        };
      }).toList();

      return fetchedNotes;
    } catch (e) {
      throw Exception("Failed to fetch notes: $e");
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
