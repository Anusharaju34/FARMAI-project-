import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _selectLanguage(
    BuildContext context,
    String languageCode,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final languages = [
      ['en', 'English'],
      ['ta', 'தமிழ் (Tamil)'],
      ['hi', 'हिन्दी (Hindi)'],
      ['te', 'తెలుగు (Telugu)'],
      ['kn', 'ಕನ್ನಡ (Kannada)'],
      ['ml', 'മലയാളം (Malayalam)'],
      ['mr', 'मराठी (Marathi)'],
      ['gu', 'ગુજરાતી (Gujarati)'],
      ['pa', 'ਪੰਜਾਬੀ (Punjabi)'],
      ['bn', 'বাংলা (Bengali)'],
      ['or', 'ଓଡ଼ିଆ (Odia)'],
      ['as', 'অসমীয়া (Assamese)'],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              const Icon(
                Icons.language,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                'Choose Your Preferred Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Select the language you want to use in FARMAI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _selectLanguage(
                            context,
                            languages[index][0],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            languages[index][1],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}