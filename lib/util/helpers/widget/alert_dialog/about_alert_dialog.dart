import 'package:flashi/provider/check_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Animated About Dialog"),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () => Provider.of<ThemeProvider>(context, listen: false)
                .toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showAnimatedAboutDialog(context),
          child: Text("Show About"),
        ),
      ),
    );
  }
}

void showAnimatedAboutDialog(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final checkVersionProvider = Provider.of<CheckVersionProvider>(context,listen: false);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (context, anim1, anim2) => SizedBox(),
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_rounded, size: 40, color: colorScheme.primary),
                  SizedBox(height: 10),
                  Text(
                    "About This App",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 5),
                  Divider(color: colorScheme.outline),
                  _buildInfoTile(context, Icons.rocket_launch, "Version", checkVersionProvider.currentVersion),
                  _buildInfoTile(context, Icons.person, "Developer", "Curib Tech"),
                  _buildInfoTile(context, Icons.email, "Contact", "curibtech@gmail.com"),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.check,color: colorScheme.onPrimary,),
                    label: Text("Got It!"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildInfoTile(
    BuildContext context, IconData icon, String title, String subtitle) {
  final colorScheme = Theme.of(context).colorScheme;
  return ListTile(
    leading: Icon(icon, color: colorScheme.primary),
    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
    subtitle: Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    tileColor: colorScheme.surfaceVariant.withOpacity(0.2),
    contentPadding: EdgeInsets.symmetric(horizontal: 20),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
