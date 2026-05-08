// lib/screens/public/feedback_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/feedback_service.dart';
import '../../core/services/hive_service.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  final FeedbackService service = FeedbackService();
  final TextEditingController messageController = TextEditingController();

  String feedbackType = "technical";
  String targetRole = "general";
  int rating = 5;
  bool loading = false;
  List<File> screenshots = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<FeedbackCategory> feedbackCategories = [
    FeedbackCategory(
      value: "technical",
      labelEn: "Technical Issue",
      labelAm: "ቴክኒካል ችግር",
      labelOm: "Rakkoo Teknikalaa",
      icon: Icons.build,
      color: Colors.blue,
    ),
    FeedbackCategory(
      value: "model",
      labelEn: "AI Model",
      labelAm: "ኤአይ ሞዴል",
      labelOm: "Moodeelii AI",
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    FeedbackCategory(
      value: "ui",
      labelEn: "UI/UX",
      labelAm: "UI/UX",
      labelOm: "UI/UX",
      icon: Icons.design_services,
      color: Colors.orange,
    ),
    FeedbackCategory(
      value: "expert",
      labelEn: "Expert Review",
      labelAm: "የባለሙያ ግምገማ",
      labelOm: "Marii Hayyuu",
      icon: Icons.verified,
      color: Colors.teal,
    ),
    FeedbackCategory(
      value: "admin",
      labelEn: "Admin",
      labelAm: "አስተዳዳሪ",
      labelOm: "Admin",
      icon: Icons.admin_panel_settings,
      color: Colors.red,
    ),
    FeedbackCategory(
      value: "developer",
      labelEn: "Developer",
      labelAm: "ገንቢ",
      labelOm: "Developer",
      icon: Icons.code,
      color: Colors.indigo,
    ),
    FeedbackCategory(
      value: "feature",
      labelEn: "Feature Request",
      labelAm: "አዲስ ባህሪ",
      labelOm: "Fedhii Wantootaa",
      icon: Icons.star,
      color: Colors.amber,
    ),
    FeedbackCategory(
      value: "bug",
      labelEn: "Bug Report",
      labelAm: "ችግር",
      labelOm: "Bug",
      icon: Icons.bug_report,
      color: Colors.deepOrange,
    ),
    FeedbackCategory(
      value: "other",
      labelEn: "Other",
      labelAm: "ሌላ",
      labelOm: "Kan Biroo",
      icon: Icons.help_outline,
      color: Colors.grey,
    ),
  ];

  final List<RecipientCategory> recipientCategories = [
    RecipientCategory(
      value: "general",
      labelEn: "General Support",
      labelAm: "አጠቃላይ ድጋፍ",
      labelOm: "Gargaarsa Waliigalaa",
      icon: Icons.support_agent,
      color: Colors.green,
    ),
    RecipientCategory(
      value: "expert",
      labelEn: "Expert Team",
      labelAm: "የባለሙያዎች ቡድን",
      labelOm: "Garee Hayyuutii",
      icon: Icons.science,
      color: Colors.blue,
    ),
    RecipientCategory(
      value: "admin",
      labelEn: "Administration",
      labelAm: "አስተዳደር",
      labelOm: "Mammaaksa",
      icon: Icons.business_center,
      color: Colors.red,
    ),
    RecipientCategory(
      value: "developer",
      labelEn: "Development Team",
      labelAm: "የልማት ቡድን",
      labelOm: "Garee Misoomaa",
      icon: Icons.developer_mode,
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    messageController.dispose();
    super.dispose();
  }

  String tr(String en, String am, String om, String code) {
    if (code == "am") return am;
    if (code == "om") return om;
    return en;
  }

  void goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> pickScreenshot() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        screenshots.add(File(pickedFile.path));
      });
    }
  }

  void removeScreenshot(int index) {
    setState(() {
      screenshots.removeAt(index);
    });
  }

  Future<void> submit(String code) async {
    final user = HiveService.getCurrentUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            tr(
              "User not logged in. Redirecting...",
              "ተጠቃሚ አልገባም፣ ወደ መግቢያ ገጽ በመሄድ ላይ...",
              "Fayyadamaan hin seenne. Gara seensaatti deema...",
              code,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) goToLogin();
      return;
    }

    if (messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              "Please write feedback first",
              "እባክዎ መጀመሪያ አስተያየት ይጻፉ",
              "Maaloo yaada barreessi",
              code,
            ),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => loading = true);

    // TODO: Upload screenshots to Supabase Storage first
    List<String> screenshotUrls = [];

        if (screenshots.isNotEmpty) {
          screenshotUrls = await service.uploadScreenshots(
            userId: user.id ?? "",
            files: screenshots,
          );
        }

    final ok = await service.sendFeedback(
      userId: user.id ?? "",
      userEmail: user.email ?? "",
      feedbackType: feedbackType,
      targetRole: targetRole,
      message: messageController.text.trim(),
      rating: rating,
      screenshotUrls: screenshotUrls,
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (ok) {
      messageController.clear();
      setState(() {
        rating = 5;
        feedbackType = "technical";
        targetRole = "general";
        screenshots.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            tr(
              "Feedback submitted successfully! Thank you for helping us improve.",
              "አስተያየት በተሳካ ሁኔታ ተልኳል! ለማሻሻል በመርዳት እናመሰግናለን።",
              "Yaadni milkaa'inaan ergame! Garaagarummaaf nu gargaarteef galatoomaa.",
              code,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            tr(
              "Failed to submit feedback. Please check your internet connection.",
              "አስተያየት መላክ አልተሳካም። እባክዎ የበይነመረብ ግንኙነትዎን ያረጋግጡ።",
              "Yaanni ergamuu hin dandeenye. Maaloo qunnamtii intarneetii keessan sakatta'aa.",
              code,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String getFeedbackTypeLabel(String code) {
    final category = feedbackCategories.firstWhere(
      (c) => c.value == feedbackType,
      orElse: () => feedbackCategories.last,
    );
    if (code == "am") return category.labelAm;
    if (code == "om") return category.labelOm;
    return category.labelEn;
  }

  String getRecipientLabel(String code) {
    final recipient = recipientCategories.firstWhere(
      (r) => r.value == targetRole,
      orElse: () => recipientCategories.first,
    );
    if (code == "am") return recipient.labelAm;
    if (code == "om") return recipient.labelOm;
    return recipient.labelEn;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final theme = context.watch<ThemeProvider>();
    final code = lang.code;
    final isDark = theme.currentTheme == AppThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          tr("Share Your Feedback", "አስተያየት ይስጡ", "Yaada Kenni", code),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade700, Colors.green.shade500],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.feedback, size: 50, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        tr(
                          "We value your opinion!",
                          "አስተያየትዎ ለእኛ ጠቃሚ ነው!",
                          "Yaadni keessan nuuf barbaachisa!",
                          code,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr(
                          "Help us make CoffeeGuard better",
                          "ኮፊጋርድን ለማሻሻል ይርዱን",
                          "CoffeeGuard fooyyessuuf nu gargaaraa",
                          code,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Feedback Type Section
                Text(
                  tr(
                    "What is your feedback about?",
                    "አስተያየትዎ ስለምን ነው?",
                    "Yaadni keessan maal irratti?",
                    code,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Scrollable Categories
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: feedbackCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = feedbackCategories[index];
                      final isSelected = feedbackType == category.value;
                      return _CategoryChip(
                        category: category,
                        isSelected: isSelected,
                        code: code,
                        isDark: isDark,
                        onTap: () {
                          setState(() {
                            feedbackType = category.value;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Recipient Section
                Text(
                  tr(
                    "Who should receive this?",
                    "ለማን ይላክ?",
                    "Eenyuuf ergamu?",
                    code,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Scrollable Recipients
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recipientCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final recipient = recipientCategories[index];
                      final isSelected = targetRole == recipient.value;
                      return _RecipientChip(
                        recipient: recipient,
                        isSelected: isSelected,
                        code: code,
                        isDark: isDark,
                        onTap: () {
                          setState(() {
                            targetRole = recipient.value;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Rating Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(
                          "Rate your experience",
                          "ልምድዎን ደረጃ ይስጡ",
                          "Sadarkaa kennuu",
                          code,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                rating = index + 1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 36,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rating == 1
                            ? tr("Poor", "ደካማ", "Gadhee", code)
                            : rating == 2
                            ? tr("Fair", "መጠነኛ", "Giddu galeessa", code)
                            : rating == 3
                            ? tr("Good", "ጥሩ", "Gaarii", code)
                            : rating == 4
                            ? tr("Very Good", "በጣም ጥሩ", "Baayyee Gaarii", code)
                            : tr("Excellent", "በጣም ጥሩ", "Baayyee Gaarii", code),
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Message Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(
                          "Your Message",
                          "መልእክትዎ",
                          "Ergaa Keessan",
                          code,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: messageController,
                        maxLines: 6,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: tr(
                            "Write your feedback here...",
                            "አስተያየትዎን እዚህ ይጻፉ...",
                            "Yaada keessan as barreessa...",
                            code,
                          ),
                          hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Screenshot Section (Optional)
                if (screenshots.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr("Attached Screenshots", "የተያያዙ ቅጽበታዊ ገጽእቶች", "Suuraawwan", code),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: screenshots.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: FileImage(screenshots[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () => removeScreenshot(index),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // Add Screenshot Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextButton.icon(
                    onPressed: pickScreenshot,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(
                      tr("Add Screenshot", "ቅጽበታዊ ገጽእት ያያይዙ", "Suuraa Dabali", code),
                    ),
                  ),
                ),

                // Selected Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${tr("Sending to", "ለ", "Ergaa", code)} ${getRecipientLabel(code)} ${tr("as", "እንደ", "akkas", code)} ${getFeedbackTypeLabel(code)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: loading ? null : () => submit(code),
                    child: loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                tr(
                                  "Submit Feedback",
                                  "አስተያየት ላክ",
                                  "Yaada Ergi",
                                  code,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Category Chip Widget (same as before)
class _CategoryChip extends StatelessWidget {
  final FeedbackCategory category;
  final bool isSelected;
  final String code;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.code,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = code == "am"
        ? category.labelAm
        : code == "om"
        ? category.labelOm
        : category.labelEn;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? category.color
              : isDark
                  ? Colors.grey.shade800
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? category.color : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              color: isSelected ? Colors.white : category.color,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.white70
                        : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recipient Chip Widget (same as before)
class _RecipientChip extends StatelessWidget {
  final RecipientCategory recipient;
  final bool isSelected;
  final String code;
  final bool isDark;
  final VoidCallback onTap;

  const _RecipientChip({
    required this.recipient,
    required this.isSelected,
    required this.code,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = code == "am"
        ? recipient.labelAm
        : code == "om"
        ? recipient.labelOm
        : recipient.labelEn;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        decoration: BoxDecoration(
          color: isSelected
              ? recipient.color
              : isDark
                  ? Colors.grey.shade800
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? recipient.color : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: recipient.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              recipient.icon,
              color: isSelected ? Colors.white : recipient.color,
              size: 28,
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class FeedbackCategory {
  final String value;
  final String labelEn;
  final String labelAm;
  final String labelOm;
  final IconData icon;
  final Color color;

  FeedbackCategory({
    required this.value,
    required this.labelEn,
    required this.labelAm,
    required this.labelOm,
    required this.icon,
    required this.color,
  });
}

class RecipientCategory {
  final String value;
  final String labelEn;
  final String labelAm;
  final String labelOm;
  final IconData icon;
  final Color color;

  RecipientCategory({
    required this.value,
    required this.labelEn,
    required this.labelAm,
    required this.labelOm,
    required this.icon,
    required this.color,
  });
}