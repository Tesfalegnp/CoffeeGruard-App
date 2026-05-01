import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/services/language_service.dart';

class ProcessingWidget extends StatelessWidget {
  final File selectedImage;
  
  const ProcessingWidget({super.key, required this.selectedImage});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Hero(
                tag: 'selected_image',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Image.file(
                          selectedImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 15),
              Text(
                lang.translate(
                  "Analyzing your coffee leaf...",
                  "በመተንተን ላይ...",
                  "Baalaa kubbaa keessan xiinxalaa jira...",
                ),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}