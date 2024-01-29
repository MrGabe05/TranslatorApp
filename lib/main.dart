// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TranslationApp(),
    );
  }
}

class TranslationApp extends StatefulWidget {
  const TranslationApp({Key? key}) : super(key: key);

  @override
  _TranslationAppState createState() => _TranslationAppState();
}

class _TranslationAppState extends State<TranslationApp> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  String _text = "";
  String? _translatedText = "";
  String _sourceLanguage = 'es';
  String _targetLanguage = 'en';
  double _buttonOpacity = 1.0;

  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    initTts();

    _sourceLanguage = 'es';
    _targetLanguage = 'en';
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  void _initSpeech() async {
    await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          Future.delayed(const Duration(milliseconds: 500), () {
            String detectedLanguage = detectLanguage(string: _text);
            if (_sourceLanguage != detectedLanguage) {
              String temp = _sourceLanguage;
              _sourceLanguage = _targetLanguage;
              _targetLanguage = temp;
            }

            translateText(_text, _sourceLanguage, _targetLanguage);

            stopListening();
          });
        }
      },
    );
    setState(() {});
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();
    _getDefaultEngine();
    _getDefaultVoice();

    flutterTts.setStartHandler(() {
      setState(() {
      });
    });

    flutterTts.setInitHandler(() {
      setState(() {
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
      });
    });
  }

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_translatedText != null) {
      if (_translatedText!.isNotEmpty) {
        await flutterTts.speak(_translatedText!);
      }
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.black],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: kToolbarHeight),
              Text(
                _text,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 40),
              InkWell(
                onTap: () {
                  if (!_isListening) {
                    startListening();
                  } else {
                    stopListening();
                  }
                },
                child: Opacity(
                  opacity: _buttonOpacity,
                  child: Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                      color: Colors.grey,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 60.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    buildLanguageSelector(_sourceLanguage, 'first'),
                    const Icon(
                      Icons.compare_arrows,
                      color: Colors.white,
                    ),
                    buildLanguageSelector(_targetLanguage, 'second'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _translatedText!,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLanguageSelector(String selectedLanguage, String label) {
    return ElevatedButton(
      onPressed: () {
        showLanguageDialog(selectedLanguage, label);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          getLanguageDisplayName(selectedLanguage),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Spanish';
      case 'en':
        return 'English';
      case 'fr':
        return 'French';
      case 'pt':
        return 'Portuguese';
      case 'ja':
        return 'Japanese';
      case 'zh':
        return 'Chinese';
      case 'de':
        return 'German';
      case 'it':
        return 'Italian';
      default:
        return languageCode;
    }
  }

  void startListening() {
    _speechToText.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
      },
    );
    setState(() {
      _isListening = true;
      _buttonOpacity = 0.5;
    });
  }

  String detectLanguage({required String string}) {
    String languageCodes = 'en';

    final RegExp english = RegExp(r'^[a-zA-Z]+');
    final RegExp chinese = RegExp(r'^[\u4E00-\u9FFF]+');
    final RegExp japanese = RegExp(r'^[\u3040-\u30FF]+');
    final RegExp korean = RegExp(r'^[\uAC00-\uD7AF]+');
    final RegExp italian = RegExp(r'^[\u00C0-\u017F]+');
    final RegExp french = RegExp(r'^[\u00C0-\u017F]+');
    final RegExp spanish = RegExp(r'[\u00C0-\u024F\u1E00-\u1EFF\u2C60-\u2C7F\uA720-\uA7FF\u1D00-\u1D7F]+');

    if (english.hasMatch(string)) languageCodes = 'en';
    if (chinese.hasMatch(string)) languageCodes = 'zh';
    if (japanese.hasMatch(string)) languageCodes = 'ja';
    if (korean.hasMatch(string)) languageCodes = 'ko';
    if (italian.hasMatch(string)) languageCodes = 'it';
    if (french.hasMatch(string)) languageCodes = 'fr';
    if (spanish.hasMatch(string)) languageCodes = 'es';

    return languageCodes;
  }

  void stopListening() {
    _speechToText.stop();

    setState(() {
      _isListening = false;
      _buttonOpacity = 1.0;
    });
  }

  Future<void> translateText(String text, String sourceLenguage, String targetLanguage) async {
    final translator = GoogleTranslator();
    translator.translate(text, from: sourceLenguage, to: targetLanguage).then((result) => {
      setState(() {
        _translatedText = result.text;

        _speak();
      })
    });
  }

  Future<void> showLanguageDialog(String selectedLanguage, String label) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                buildLanguageButton('Spanish', 'es', label, selectedLanguage),
                buildLanguageButton('English', 'en', label, selectedLanguage),
                buildLanguageButton('French', 'fr', label, selectedLanguage),
                buildLanguageButton('Portuguese', 'pt', label, selectedLanguage),
                buildLanguageButton('Japanese', 'ja', label, selectedLanguage),
                buildLanguageButton('Chinese', 'zh', label, selectedLanguage),
                buildLanguageButton('German', 'de', label, selectedLanguage),
                buildLanguageButton('Italian', 'it', label, selectedLanguage),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildLanguageButton(String languageName, String languageCode, String label, String selectedLanguage) {
    return TextButton(
      onPressed: () {
        setState(() {
          if (label == 'first') {
            _sourceLanguage = languageCode;
          } else if (label == 'second') {
            _targetLanguage = languageCode;
          }
        });
        Navigator.of(context).pop();
      },
      child: Text(
        getLanguageDisplayName(languageCode),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}