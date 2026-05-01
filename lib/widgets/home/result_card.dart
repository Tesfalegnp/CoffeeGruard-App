import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/services/language_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/text_animator.dart';
import '../../models/recommendation_model.dart';

class ResultCard extends StatefulWidget {
  final File? selectedImage;
  final String disease;
  final double? confidence;
  final String recommendation;
  final RecommendationModel? currentRecommendationModel;
  final bool isCoffeeLeaf;
  final VoidCallback onReset;
  final VoidCallback onLanguageToggle;
  final FlutterTts tts;
  final bool isSpeaking;
  final VoidCallback onSpeak;
  final VoidCallback onStopSpeak;
  final TextAnimator textAnimator;
  final String displayedText;
  
  const ResultCard({
    super.key,
    this.selectedImage,
    required this.disease,
    this.confidence,
    required this.recommendation,
    this.currentRecommendationModel,
    required this.isCoffeeLeaf,
    required this.onReset,
    required this.onLanguageToggle,
    required this.tts,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onStopSpeak,
    required this.textAnimator,
    required this.displayedText,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final percent = widget.confidence != null ? (widget.confidence! * 100).toStringAsFixed(1) : "0";
    final statusColor = AppTheme.getStatusColor(widget.disease, widget.isCoffeeLeaf);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [Colors.grey.shade800, Colors.green.shade900]
                          : [Colors.white, Colors.green.shade50],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (widget.selectedImage != null)
                          Hero(
                            tag: 'selected_image',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                widget.selectedImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor, width: 2),
                          ),
                          child: Text(
                            widget.disease,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (widget.confidence != null) ...[
                          const SizedBox(height: 15),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.green.shade900 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.translate("Confidence", "ትክክለኛነት", "Mirkanayyummaa"),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                    ),
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0, end: double.parse(percent)),
                                      duration: const Duration(milliseconds: 1000),
                                      builder: (context, double value, child) {
                                        return Text(
                                          "${value.toStringAsFixed(1)}%",
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: widget.confidence,
                                    minHeight: 12,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation(statusColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isDarkMode ? Colors.blue.shade400 : Colors.blue.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.lightbulb, color: Colors.amber.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        lang.translate("Recommendation", "ምክር", "Gorsa"),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.green.shade800 : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextButton.icon(
                                      onPressed: widget.onLanguageToggle,
                                      icon: Icon(Icons.translate, color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700),
                                      label: Text(
                                        lang.translate("English", "አማርኛ", "Oromoo"),
                                        style: TextStyle(color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  widget.displayedText,
                                  key: ValueKey(widget.displayedText),
                                  style: GoogleFonts.poppins(height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (widget.isSpeaking) {
                                      widget.onStopSpeak();
                                    } else {
                                      widget.onSpeak();
                                    }
                                  },
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      widget.isSpeaking ? Icons.stop : Icons.volume_up,
                                      key: ValueKey(widget.isSpeaking),
                                    ),
                                  ),
                                  label: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      widget.isSpeaking 
                                          ? lang.translate("Stop", "አቁም", "Dhaabi")
                                          : lang.translate("Read Aloud", "ማንበብ", "Dubbisi"),
                                      key: ValueKey(widget.isSpeaking),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onReset,
                                icon: const Icon(Icons.camera_alt),
                                label: Text(lang.translate("Scan Again", "እንደገና ፎቶ አንሳ", "Itti Fudhi"),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green.shade700,
                                  side: BorderSide(color: Colors.green.shade700),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onReset,
                                icon: const Icon(Icons.clear),
                                label: Text(lang.translate("Clear", "አጽዳ", "Haqu"),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(color: Colors.red.shade700),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}