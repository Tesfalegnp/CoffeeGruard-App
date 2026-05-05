import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/feedback_service.dart';
import '../../core/services/hive_service.dart';
import '../../providers/language_provider.dart';

import '../auth/login_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() =>
      _FeedbackScreenState();
}

class _FeedbackScreenState
    extends State<FeedbackScreen> {
  final FeedbackService service = FeedbackService();

  final TextEditingController messageController =
      TextEditingController();

  String feedbackType = "technical";
  String targetRole = "developer";
  int rating = 3;

  bool loading = false;

  /// ==============================
  /// LANGUAGE HELPER
  /// ==============================
  String tr(
    String en,
    String am,
    String om,
    String code,
  ) {
    if (code == "am") return am;
    if (code == "om") return om;
    return en;
  }

  /// ==============================
  /// NAVIGATE TO LOGIN
  /// ==============================
  void goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  /// ==============================
  /// SUBMIT FEEDBACK
  /// ==============================
  Future<void> submit(String code) async {
    final user =
        HiveService.getCurrentUser();

    /// ❌ NOT LOGGED IN CASE
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
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
        ),
      );

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (mounted) goToLogin();

      return;
    }

    /// ❌ EMPTY MESSAGE CHECK
    if (messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            tr(
              "Please write feedback first",
              "እባክዎ መጀመሪያ አስተያየት ይጻፉ",
              "Maaloo yaada barreessi",
              code,
            ),
          ),
        ),
      );
      return;
    }

    setState(() => loading = true);

    final ok = await service.sendFeedback(
      userId: user.id ?? "",
      userEmail: user.email ?? "",
      feedbackType: feedbackType,
      targetRole: targetRole,
      message: messageController.text.trim(),
      rating: rating,
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (ok) {
      messageController.clear();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            tr(
              "Feedback submitted successfully",
              "አስተያየት በተሳካ ሁኔታ ተልኳል",
              "Yaadni milkaa'inaan ergame",
              code,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            tr(
              "Failed to submit feedback",
              "አስተያየት መላክ አልተሳካም",
              "Ergaa hin milkoofne",
              code,
            ),
          ),
        ),
      );
    }
  }

  /// ==============================
  /// UI
  /// ==============================
  @override
  Widget build(BuildContext context) {
    final lang =
        context.watch<LanguageProvider>();

    final code = lang.code;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.green.shade700,
        title: Text(
          tr(
            "Feedback",
            "አስተያየት",
            "Yaada",
            code,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TYPE
            DropdownButtonFormField(
              value: feedbackType,
              decoration: InputDecoration(
                labelText: tr(
                  "Feedback Type",
                  "ዓይነት",
                  "Gosa yaada",
                  code,
                ),
              ),
              items: const [
                DropdownMenuItem(
                    value: "technical",
                    child:
                        Text("Technical")),
                DropdownMenuItem(
                    value: "model",
                    child:
                        Text("AI Model")),
                DropdownMenuItem(
                    value: "ui",
                    child: Text("UI/UX")),
                DropdownMenuItem(
                    value: "expert",
                    child: Text("Expert")),
                DropdownMenuItem(
                    value: "admin",
                    child: Text("Admin")),
                DropdownMenuItem(
                    value: "developer",
                    child:
                        Text("Developer")),
                DropdownMenuItem(
                    value: "other",
                    child: Text("Other")),
              ],
              onChanged: (v) => setState(
                  () => feedbackType = v!),
            ),

            const SizedBox(height: 12),

            /// TARGET ROLE
            DropdownButtonFormField(
              value: targetRole,
              decoration: InputDecoration(
                labelText: tr(
                  "Send To",
                  "ለማን",
                  "Eenyuf",
                  code,
                ),
              ),
              items: const [
                DropdownMenuItem(
                    value: "general",
                    child:
                        Text("General")),
                DropdownMenuItem(
                    value: "expert",
                    child: Text("Expert")),
                DropdownMenuItem(
                    value: "admin",
                    child: Text("Admin")),
                DropdownMenuItem(
                    value: "developer",
                    child:
                        Text("Developer")),
              ],
              onChanged: (v) => setState(
                  () => targetRole = v!),
            ),

            const SizedBox(height: 12),

            /// RATING
            Row(
              children: [
                Text(tr(
                  "Rating",
                  "ደረጃ",
                  "Sadarkaa",
                  code,
                )),
                Expanded(
                  child: Slider(
                    value: rating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: "$rating",
                    onChanged: (v) =>
                        setState(() =>
                            rating = v.toInt()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// MESSAGE
            TextField(
              controller:
                  messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: tr(
                  "Write feedback...",
                  "ጻፉ...",
                  "Barreessi...",
                  code,
                ),
                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 14,
                  ),
                ),
                onPressed: loading
                    ? null
                    : () => submit(code),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        tr(
                          "Submit Feedback",
                          "ላክ",
                          "Ergi",
                          code,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}