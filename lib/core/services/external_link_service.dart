import 'package:url_launcher/url_launcher.dart';

class ExternalLinkService {
  final String url;

  ExternalLinkService(this.url);

  /// This method launches any URL passed to it dynamically.
  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(this.url);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  // This function will open the default email app with pre-filled details
  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'curibtech@gmail.com', // Recipient email address
      query: Uri.encodeFull(
          'subject=Contact Us&body=Hello, I would like to...'), // Pre-filled subject and body
    );
    launchUrl(emailUri);
  }

  // Add a method to trigger the URL launch
  void launch() {
    _launchUrl();
  }

  // Add a method to trigger the URL launch
  void launchEmail() {
    _launchEmail();
  }
}
