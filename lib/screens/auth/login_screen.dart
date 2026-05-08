import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/hive_service.dart';
import '../../models/user_model.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../admin/admin_dashboard.dart';
import '../expert/expert_dashboard.dart';
import '../home/hero_home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final SupabaseService supabaseService = SupabaseService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }

  Future<void> handleLogin() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isAmharic = langProvider.code == 'am';
    final isOromo = langProvider.code == 'om';

    if (emailController.text.trim().isEmpty || 
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAmharic 
                ? "ኢሜይል እና ይለፍ ቃል ያስፈልጋል"
                : isOromo
                ? "Imeeliifi jacha barbaachisa"
                : "Email and password are required",
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final user = await supabaseService.loginUser(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAmharic 
                ? "ኢሜይል ወይም ይለፍ ቃል ተሳስቷል"
                : isOromo
                ? "Imeeliin ykn jachi sirri miti"
                : "Invalid email or password",
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    /// ✅ SAVE SESSION
    final userModel = UserModel(
      id: user["id"],
      email: user["email"],
      role: user["role"],
      fullName: user["full_name"],
      phone: user["phone"],
      avatarUrl: user["avatar_url"],
    );

    await HiveService.saveUserSession(userModel);

    final role = user["role"];

    // Add smooth transition
    if (role == "admin") {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AdminDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else if (role == "expert") {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ExpertDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HeroHomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  String _getTitle(LanguageProvider lang) {
    switch (lang.code) {
      case 'am':
        return "እንኳን ደህና መጣችሁ";
      case 'om':
        return "Bagamaan Nagaan Dhufte";
      default:
        return "Welcome Back";
    }
  }

  String _getSubtitle(LanguageProvider lang) {
    switch (lang.code) {
      case 'am':
        return "እባክዎ ወደ መለያዎ ይግቡ";
      case 'om':
        return "Maaloo akka itti fufiituu galmaa'i";
      default:
        return "Please sign in to continue";
    }
  }

  String _getEmailLabel(LanguageProvider lang) {
    switch (lang.code) {
      case 'am':
        return "ኢሜይል";
      case 'om':
        return "Imeelii";
      default:
        return "Email Address";
    }
  }

  String _getEmailHint(LanguageProvider lang) {
    switch (lang.code) {
      case 'am':
        return "ኢሜይል ያስገቡ";
      case 'om':
        return "Imeelii keessan barreessaa";
      default:
        return "Enter your email";
    }
  }

  String _getPasswordLabel(LanguageProvider lang) {
    switch (lang.code) {
      case 'am':
        return "ይለፍ ቃል";
      case 'om':
        return "Jacha";
      default:
        return "Password";
    }
  }

  String _getPasswordHint(LanguageProvider lang) {
    switch (lang.code) {
      case 'am':
        return "ይለፍ ቃል ያስገቡ";
      case 'om':
        return "Jacha keessan barreessaa";
      default:
        return "Enter your password";
    }
  }

  String _getLoginButtonText(LanguageProvider lang) {
    switch (lang.code) {
      case 'am':
        return "ግባ";
      case 'om':
        return "Seeni";
      default:
        return "Login";
    }
  }

  String _getDemoText(LanguageProvider lang) {
    switch (lang.code) {
      case 'am':
        return "የሙከራ መለያ: farmer@example.com / ይለፍ ቃል: password123";
      case 'om':
        return "Yaaluuf: farmer@example.com / Jacha: password123";
      default:
        return "Demo Account: farmer@example.com / Password: password123";
    }
  }

  String _getBackTooltip(LanguageProvider lang) {
    switch (lang.code) {
      case 'am':
        return "ወደ ዋና ገጽ";
      case 'om':
        return "Garuu Deebi'i";
      default:
        return "Back to Home";
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.currentTheme == AppThemeMode.dark;
    final isAmharic = langProvider.code == 'am';
    final isOromo = langProvider.code == 'om';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A2F0A),
                    const Color(0xFF1B5E20),
                    const Color(0xFF2E7D32),
                  ]
                : [
                    Colors.green.shade800,
                    Colors.green.shade600,
                    Colors.green.shade400,
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Custom App Bar with Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => 
                                      const HeroHomeScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            },
                            tooltip: _getBackTooltip(langProvider),
                          ),
                        ),
                        const Spacer(),
                        // Language Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAmharic ? Icons.celebration : Icons.language,
                                size: 16,
                                color: Colors.yellow.shade200,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isAmharic ? "አማርኛ" : isOromo ? "Oromoo" : "English",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Logo Container
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.eco,
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Welcome Text
                            Text(
                              _getTitle(langProvider),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getSubtitle(langProvider),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.85),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            // Login Card
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 20,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                color: isDark ? const Color(0xFF1E1E1E) : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: isDark
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFF2C2C2C),
                                              const Color(0xFF1E1E1E),
                                            ],
                                          )
                                        : LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Colors.green.shade50,
                                            ],
                                          ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Email Field
                                        Text(
                                          _getEmailLabel(langProvider),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isDark 
                                                ? Colors.green.shade300 
                                                : Colors.green.shade800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: _getEmailHint(langProvider),
                                              hintStyle: TextStyle(
                                                color: isDark 
                                                    ? Colors.grey.shade500 
                                                    : Colors.grey.shade400,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.email_outlined,
                                                color: isDark 
                                                    ? Colors.green.shade400 
                                                    : Colors.green.shade600,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Colors.green.shade600,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: isDark 
                                                  ? const Color(0xFF2C2C2C)
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // Password Field
                                        Text(
                                          _getPasswordLabel(langProvider),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isDark 
                                                ? Colors.green.shade300 
                                                : Colors.green.shade800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: passwordController,
                                            obscureText: obscurePassword,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: _getPasswordHint(langProvider),
                                              hintStyle: TextStyle(
                                                color: isDark 
                                                    ? Colors.grey.shade500 
                                                    : Colors.grey.shade400,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.lock_outline,
                                                color: isDark 
                                                    ? Colors.green.shade400 
                                                    : Colors.green.shade600,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  obscurePassword 
                                                      ? Icons.visibility_off 
                                                      : Icons.visibility,
                                                  color: isDark 
                                                      ? Colors.green.shade400 
                                                      : Colors.green.shade600,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    obscurePassword = !obscurePassword;
                                                  });
                                                },
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Colors.green.shade600,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: isDark 
                                                  ? const Color(0xFF2C2C2C)
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        // Login Button
                                        SizedBox(
                                          width: double.infinity,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green.shade600,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                elevation: 3,
                                              ),
                                              onPressed: isLoading ? null : handleLogin,
                                              child: isLoading
                                                  ? SizedBox(
                                                      height: 22,
                                                      width: 22,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.login_rounded,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          _getLoginButtonText(langProvider),
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),

                                            // Forgot Password
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => const ForgotPasswordScreen(),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  "Forgot Password?",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 10),

                                            // Create Account
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                icon: const Icon(Icons.person_add),
                                                label: const Text("Create Account"),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.green,
                                                  side: const BorderSide(color: Colors.green),
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 15,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => const RegisterScreen(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),

                                            const SizedBox(height: 24),
                                        // Demo Credentials Info
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: (isDark 
                                                ? Colors.blue.shade900 
                                                : Colors.blue.shade50).withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                              color: isDark 
                                                  ? Colors.blue.shade700 
                                                  : Colors.blue.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: isDark 
                                                    ? Colors.blue.shade300 
                                                    : Colors.blue.shade700,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _getDemoText(langProvider),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark 
                                                        ? Colors.blue.shade300 
                                                        : Colors.blue.shade700,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}