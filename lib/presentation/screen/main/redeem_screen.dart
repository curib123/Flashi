import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import for provider

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RedeemScreenContent();
  }
}

class RedeemScreenContent extends StatelessWidget {
  const RedeemScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.notes_rounded, size: 30, color: colorScheme.onPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: ReusableTitleContent(
          colorScheme: colorScheme,
          title: "Redeem",
          onUpgradePro: () {},
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: Consumer<TokenProvider>(
        builder: (context, tokenProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,       // Start color
                          colorScheme.primaryContainer.withOpacity(0.3), // End color
                        ],
                        begin: Alignment.topLeft,   // Starting point of the gradient
                        end: Alignment.bottomRight, // Ending point of the gradient
                      ),
                      borderRadius: BorderRadius.circular(8),  // Rounded corners
                    ),
                    padding: EdgeInsets.all(16),  // Padding inside the container
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Withdraw via GCash", // Label for GCash withdrawal
                          style: TextStyle(
                              fontSize: 20,
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Tokens Available", // Show current tokens for withdrawal
                          style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "${tokenProvider.convertedValue}", // Show current tokens for withdrawal
                          style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ],
                    ),
                  )

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
