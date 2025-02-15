import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/provider/text_reader_provider.dart';
import 'package:flashi/util/helpers/ads/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class ReusableTextReader extends StatefulWidget {
  const ReusableTextReader({super.key});

  @override
  State<ReusableTextReader> createState() => _ReusableTextReaderState();
}

class _ReusableTextReaderState extends State<ReusableTextReader> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isReading = false;


  var startAppSdk = StartAppSdk();
  double bannerHeight = 150.0;

  StartAppBannerAd? bannerAd;

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(AdHelper.isTestEnabled);

    // TODO use one of the following types: BANNER, MREC, COVER
    startAppSdk.loadBannerAd(StartAppBannerType.BANNER).then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;
        bannerHeight = 150;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
      bannerHeight = 0;
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
      bannerHeight = 0;
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isReading = false;
      });
    });

    // Set up speech rate and volume for smooth speech
    _flutterTts.setSpeechRate(0.5); // Default is 0.5 (normal speed)
    _flutterTts.setVolume(1.0); // Set volume to maximum
    _flutterTts.setLanguage('en-US'); // Set the language to English (US)
  }

  Future<void> _startReading() async {
    final text = context.read<TextReaderProvider>().textController.text.trim();
    if (text.isEmpty) return; // Prevent reading empty text

    setState(() {
      _isReading = true;
    });

    // Start reading the entire text
    await _flutterTts.speak(text);
  }

  Future<void> _stopReading() async {
    await _flutterTts.stop();
    setState(() {
      _isReading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textReaderProvider = Provider.of<TextReaderProvider>(context);




    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 20,right: 20,top: 20),
            child: Column(
              children: [
                // Text Input Field

                bannerAd != null ? StartAppBanner(bannerAd!) : Container(),
                TextField(
                  controller: textReaderProvider.textController,
                  maxLines: 23,
                  decoration: const InputDecoration(
                    hintText: "Paste or type your text here...",
                    border: InputBorder.none,
                  ),
                  onChanged: (newText) {
                    textReaderProvider.updateText(newText,true); // Update provider text
                  },
                ),
              ],
            ),
          ),
        ),
        ReusableCreateSetButtonPosition(
          icon: _isReading ? Icons.stop : Icons.volume_up,
          colorScheme: colorScheme,
          name: _isReading ? "Stop Reading" : "Start Reading",
          onTap: _isReading ? _stopReading : _startReading,
        ),
        ReusableThemeSettingPosition(colorScheme: colorScheme),
      ],
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
