// =======================================================
// lib/screens/auth/forgot_password_screen.dart
// FULL WORKING RESET PASSWORD SCREEN
// =======================================================

import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final SupabaseService service = SupabaseService();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();

  final newPasswordController = TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  bool loading = false;
  bool userVerified = false;

  bool hidePass = true;
  bool hideConfirm = true;

  // ======================================
  // STEP 1 VERIFY USER
  // ======================================
  Future<void> verifyUser() async {
    final fullName =
        fullNameController.text.trim();
    final email = emailController.text.trim();

    if (fullName.isEmpty || email.isEmpty) {
      showMsg("Fill all fields", Colors.red);
      return;
    }

    setState(() => loading = true);

    final ok = await service.verifyUserForReset(
      fullName: fullName,
      email: email,
    );

    setState(() => loading = false);

    if (ok) {
      setState(() => userVerified = true);

      showMsg(
        "User verified. Enter new password.",
        Colors.green,
      );
    } else {
      showMsg(
        "Name or Email not matched.",
        Colors.red,
      );
    }
  }

  // ======================================
  // STEP 2 RESET PASSWORD
  // ======================================
  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    final pass =
        newPasswordController.text.trim();
    final confirm =
        confirmPasswordController.text.trim();

    if (pass.length < 6) {
      showMsg(
        "Password must be at least 6 characters",
        Colors.red,
      );
      return;
    }

    if (pass != confirm) {
      showMsg(
        "Passwords do not match",
        Colors.red,
      );
      return;
    }

    setState(() => loading = true);

    final ok =
        await service.resetPasswordDirectly(
      email: email,
      newPassword: pass,
    );

    setState(() => loading = false);

    if (ok) {
      showMsg(
        "Password updated successfully",
        Colors.green,
      );

      Navigator.pop(context);
    } else {
      showMsg(
        "Failed to update password",
        Colors.red,
      );
    }
  }

  void showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.lock_reset,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              "Recover your account",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // FULL NAME
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon:
                    const Icon(Icons.person),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // EMAIL
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon:
                    const Icon(Icons.email),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // VERIFY BUTTON
            if (!userVerified)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      loading ? null : verifyUser,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color:
                              Colors.white,
                        )
                      : const Text(
                          "Verify User",
                          style: TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                ),
              ),

            // SHOW AFTER VERIFY SUCCESS
            if (userVerified) ...[
              const SizedBox(height: 20),

              TextField(
                controller:
                    newPasswordController,
                obscureText: hidePass,
                decoration:
                    InputDecoration(
                  labelText:
                      "New Password",
                  prefixIcon:
                      const Icon(
                          Icons.lock),
                  suffixIcon:
                      IconButton(
                    icon: Icon(
                      hidePass
                          ? Icons
                              .visibility
                          : Icons
                              .visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePass =
                            !hidePass;
                      });
                    },
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                15),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller:
                    confirmPasswordController,
                obscureText:
                    hideConfirm,
                decoration:
                    InputDecoration(
                  labelText:
                      "Confirm Password",
                  prefixIcon:
                      const Icon(
                          Icons.lock),
                  suffixIcon:
                      IconButton(
                    icon: Icon(
                      hideConfirm
                          ? Icons
                              .visibility
                          : Icons
                              .visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        hideConfirm =
                            !hideConfirm;
                      });
                    },
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                15),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      loading
                          ? null
                          : resetPassword,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color:
                              Colors.white,
                        )
                      : const Text(
                          "Update Password",
                          style: TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}