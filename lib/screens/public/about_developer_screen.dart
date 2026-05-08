
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';

class AboutDeveloperScreen extends StatefulWidget {
  const AboutDeveloperScreen({super.key});

  @override
  State<AboutDeveloperScreen> createState() => _AboutDeveloperScreenState();
}

class _AboutDeveloperScreenState extends State<AboutDeveloperScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _headerController.dispose();
    super.dispose();
  }

  String tr(String en, String am, String om, String code) {
    if (code == "am") return am;
    if (code == "om") return om;
    return en;
  }

  Future<void> _openLink(String url) async {
    try {
      if (!url.startsWith("http")) {
        url = "https://$url";
      }
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  Future<void> _call(String phone) async {
    await launchUrl(Uri.parse("tel:$phone"));
  }

  Future<void> _mail(String email) async {
    await launchUrl(Uri.parse("mailto:$email"));
  }

  Future<void> _telegram(String tg) async {
    String value = tg;

    if (value.contains("http")) {
      await _openLink(value);
      return;
    }

    value = value.replaceAll("@", "");
    await _openLink("https://t.me/$value");
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<DeveloperModel> developers(String code) {
    return [
      DeveloperModel(
        name: "Tesfalegn Petros",
        role: tr("AI Engineer", "የAI መሐንዲስ", "Injinerii AI", code),
        image: "assets/developers/Tesfalegn.jpg",
        phone: "+251916225842",
        email: "peterhope935@gmail.com",
        telegram: "https://t.me/tesfa935",
        website: "https://tesfalegnp.github.io/Tesfalegn_portfolio/",
        about: tr(
          "🎓 AI & ML Specialist | 5+ years experience\n🤖 Computer Vision Expert\n🌱 Passionate about Ethiopian Agriculture\n📊 TensorFlow & PyTorch Certified\n💡 Built 10+ Production AI Models",
          "🎓 የAI እና ML ስፔሻሊስት | 5+ ዓመታት ልምድ\n🤖 የኮምፒውተር እይታ ኤክስፐርት\n🌱 ለኢትዮጵያ ግብርና ትጋት\n📊 TensorFlow እና PyTorch እውቅና\n💡 10+ የምርት AI ሞዴሎችን ገንብቷል",
          "🎓 Ogessa AI fi ML | 5+ wgg\n🤖 Ogeessa Mul'ataa Kombiyuuteraa\n🌱 Haqeenya Qonnaan Itoophiyaa\n📊 TensorFlow fi PyTorch\n💡 10+ Adorsa AI",
          code,
        ),
        color: const Color(0xFF4CAF50),
        skills: ["Python", "TensorFlow", "Flutter", "Computer Vision"],
      ),
      DeveloperModel(
        name: "Bayisa Demise",
        role: tr("Backend Developer", "የBackend አበልጻጊ", "Backend Developer", code),
        image: "assets/developers/Bayisa.jpg",
        phone: "+251948249818",
        email: "bayisa@coffeeguard.app",
        telegram: "https://t.me/bayisa_backend",
        website: "https://bayisa.dev",
        about: tr(
          "🚀 Senior Backend Engineer\n🗄️ Database Architect & API Expert\n☁️ Cloud Infrastructure Specialist\n🔒 Security-First Development\n⚡ Scalable Systems Design",
          "🚀 ከፍተኛ የBackend መሐንዲስ\n🗄️ የውሂብ ጎታ አርክቴክት እና API ኤክስፐርት\n☁️ የCloud መሠረተ ልማት ስፔሻሊስት\n🔒 ደህንነትን ያማከለ ልማት\n⚡ የሚስፋፋ የስርዓት ዲዛይን",
          "🚀 Injineriya Backend\n🗄️ Database Architect fi API\n☁️ System Cloud\n🔒 Development Safeguard",
          code,
        ),
        color: const Color(0xFF2196F3),
        skills: ["Node.js", "PostgreSQL", "Supabase", "Docker"],
      ),
      DeveloperModel(
        name: "Fromisa Dine",
        role: tr("Frontend Developer", "Frontend አበልጻጊ", "Frontend Developer", code),
        image: "assets/developers/Fromisa.jpg",
        phone: "+251972775428",
        email: "fromisa@coffeeguard.app",
        telegram: "https://t.me/Firomsa3",
        website: "https://flutter.dev",
        about: tr(
          "🎨 UI/UX Specialist\n📱 Flutter & Mobile Expert\n✨ Smooth Animations & Transitions\n🎯 Performance Optimization\n🔄 Real-time App Architect",
          "🎨 የUI/UX ስፔሻሊስት\n📱 Flutter እና ሞባይል ኤክስፐርት\n✨ ለስላሳ እንቅስቃሴዎች\n🎯 አፈጻጸም ማሻሻያ\n🔄 የቀጥታ መተግበሪያ አርክቴክት",
          "🎨 UI/UX Specialist\n📱 Flutter fi Mobile\n✨ Animations\n🎯 Performance\n🔄 App Architect",
          code,
        ),
        color: const Color(0xFFE65100),
        skills: ["Flutter", "Dart", "Firebase", "GetX"],
      ),
      DeveloperModel(
        name: "Eden Atinafe",
        role: tr("Documentation Expert", "የሰነድ ባለሙያ", "Barreessaa", code),
        image: "assets/developers/Eden.jpg",
        phone: "+251912823205",
        email: "eden@coffeeguard.app",
        telegram: "https://t.me/Alice_ff90",
        website: "https://google.com",
        about: tr(
          "📚 Technical Writer & Documentation Lead\n📊 System Documentation Specialist\n🎓 User Guide & API Documentation\n🔍 Quality Assurance Expert\n📈 Project Documentation Manager",
          "📚 ቴክኒካል ጸሐፊ እና የሰነድ መሪ\n📊 የስርዓት ሰነድ ስፔሻሊስት\n🎓 የተጠቃሚ መመሪያ እና API ሰነድ\n🔍 የጥራት ማረጋገጫ ኤክስፐርት\n📈 የፕሮጀክት ሰነድ አስተዳዳሪ",
          "📚 Technical Writer\n📊 System Documentation Specialist\n🎓 User Guide & API\n🔍 Quality Assurance\n📈 Project Manager",
          code,
        ),
        color: const Color(0xFF9C27B0),
        skills: ["Technical Writing", "Documentation", "QA", "Project Management"],
      ),
      DeveloperModel(
        name: "Nyok Biliu",
        role: tr("API Integrator", "API አቀናባሪ", "API Integrator", code),
        image: "assets/developers/nyok.jpg",
        phone: "+251985189790",
        email: "nyok@coffeeguard.app",
        telegram: "https://t.me/Weber_NBK",
        website: "https://google.com",
        about: tr(
          "🔌 API Integration Specialist\n🔄 System Connectivity Expert\n📡 Third-party Service Integration\n⚙️ Middleware Development\n🌐 Cross-platform Solutions",
          "🔌 የAPI ውህደት ስፔሻሊስት\n🔄 የስርዓት ትስስር ኤክስፐርት\n📡 የሶስተኛ ወገን አገልግሎት ውህደት\n⚙️ መካከለኛ ሶፍትዌር ልማት\n🌐 ሁለንተናዊ መፍትሄዎች",
          "🔌 API Integration Specialist\n🔄 System Connectivity Expert\n📡 Third-party Service\n⚙️ Middleware Development",
          code,
        ),
        color: const Color(0xFF00897B),
        skills: ["REST API", "GraphQL", "Webhooks", "Middleware"],
      ),
    ];
  }

  void _showDeveloperDetails(DeveloperModel dev, String code, bool dark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Hero Image
                    Hero(
                      tag: dev.name,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: dev.color.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundImage: AssetImage(dev.image),
                          onBackgroundImageError: (_, __) {},
                          child: dev.image.isEmpty
                              ? Icon(Icons.person, size: 65, color: dev.color)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      dev.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: dark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: dev.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dev.role,
                        style: TextStyle(
                          color: dev.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Skills Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dev.skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: dark 
                                ? Colors.grey.shade800 
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: dev.color.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              fontSize: 12,
                              color: dark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // About Text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dark 
                            ? Colors.grey.shade900 
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dev.about,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: dark ? Colors.grey.shade300 : Colors.black87,
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Contact Actions
                    Text(
                      tr("Connect With Me", "አግኙኝ", "Na Quunnama", code),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: dark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _ContactTile(
                      icon: Icons.phone,
                      text: dev.phone,
                      color: Colors.green,
                      onTap: () {
                        _showSnack(
                          tr("Calling...", "እየደወልኩ ነው...", "Bilbilaa...", code),
                          Colors.green,
                        );
                        _call(dev.phone);
                      },
                    ),
                    _ContactTile(
                      icon: Icons.email,
                      text: dev.email,
                      color: Colors.blue,
                      onTap: () {
                        _showSnack(
                          tr("Opening Email...", "ኢሜይል እየከፈትኩ ነው...", "Email banamaa...", code),
                          Colors.blue,
                        );
                        _mail(dev.email);
                      },
                    ),
                    _ContactTile(
                      icon: Icons.telegram,
                      text: "Telegram",
                      color: const Color(0xFF26A5E4),
                      onTap: () {
                        _showSnack(
                          tr("Opening Telegram...", "ቴሌግራም እየከፈትኩ ነው...", "Telegram banamaa...", code),
                          const Color(0xFF26A5E4),
                        );
                        _telegram(dev.telegram);
                      },
                    ),
                    _ContactTile(
                      icon: Icons.language,
                      text: tr("Portfolio", "ፖርትፎሊዮ", "Industee", code),
                      color: Colors.purple,
                      onTap: () {
                        _showSnack(
                          tr("Opening Website...", "ድረገጽ እየከፈትኩ ነው...", "Wabbo banamaa...", code),
                          Colors.purple,
                        );
                        _openLink(dev.website);
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dev.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          tr("Close", "ዝጋ", "Cufi", code),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    final code = lang.code;
    final dark = theme.currentTheme == AppThemeMode.dark;

    final developers = this.developers(code);

    return Scaffold(
      backgroundColor: dark ? Colors.black : Colors.grey.shade100,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Custom Animated App Bar
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: Colors.green.shade700,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  tr("Meet Our Team", "ቡድናችንን ይወቁ", "Garee Keenya Beeki", code),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade900,
                            Colors.green.shade700,
                            Colors.green.shade500,
                          ],
                        ),
                      ),
                    ),
                    // Animated Background Pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: AnimatedBuilder(
                          animation: _headerController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _headerController.value * 3.14159 * 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Center Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                                scale: _fadeAnimation,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    image: const DecorationImage(
                                      image: AssetImage("assets/developers/Team.jpg"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                          const SizedBox(height: 16),
                          SlideTransition(
                            position: _slideAnimation,
                            child: Text(
                              tr(
                                "Professional Development Team",
                                "ባለሙያ የልማት ቡድን",
                                "Garee Misoomaa",
                                code,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr(
                              "Dedicated to Excellence in Coffee Disease Detection",
                              "ለቡና በሽታ መለየት ልዩ ትጋት",
                              "Addabbii Dhukkuba Bunaa",
                              code,
                            ),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Team Members Grid
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dev = developers[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _TeamMemberCard(
                        developer: dev,
                        dark: dark,
                        onTap: () => _showDeveloperDetails(dev, code, dark),
                      ),
                    );
                  },
                  childCount: developers.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
              ),
            ),

            // Footer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Divider(
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _headerController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.5 + (_headerController.value * 0.3),
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red.shade400,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tr(
                              "Made with passion for Ethiopian coffee farmers",
                              "ለኢትዮጵያ ቡና አርሶ አደሮች በፍቅር የተሰራ",
                              "Qonnaan bultoota bunaa Itoophiyaaf jaalalaan hojjetame",
                              code,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: dark ? Colors.grey.shade500 : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "© 2025 CoffeeGuard | v2.0.0",
                            style: TextStyle(
                              color: dark ? Colors.grey.shade600 : Colors.grey.shade400,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// TEAM MEMBER CARD
// ===============================================================

class _TeamMemberCard extends StatefulWidget {
  final DeveloperModel developer;
  final bool dark;
  final VoidCallback onTap;

  const _TeamMemberCard({
    required this.developer,
    required this.dark,
    required this.onTap,
  });

  @override
  State<_TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<_TeamMemberCard> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    final dev = widget.developer;

    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.97),
      onTapUp: (_) => setState(() => scale = 1),
      onTapCancel: () => setState(() => scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: widget.dark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: dev.color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Image with Gradient Border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [dev.color, dev.color.withOpacity(0.5)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage(dev.image),
                  onBackgroundImageError: (_, __) {},
                  child: dev.image.isEmpty
                      ? Icon(Icons.person, size: 45, color: dev.color)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              // Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  dev.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: widget.dark ? Colors.white : Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Role Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                constraints: const BoxConstraints(maxWidth: 140),
                decoration: BoxDecoration(
                  color: dev.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dev.role,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: dev.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              // Contact Button
              Padding(
                padding: const EdgeInsets.all(14),
                child: ElevatedButton.icon(
                  onPressed: widget.onTap,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 38),
                    backgroundColor: dev.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.contact_page, size: 16),
                  label: const Text(
                    "Connect",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// CONTACT TILE
// ===============================================================

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withOpacity(0.08),
              border: Border.all(
                color: color.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// DEVELOPER MODEL
// ===============================================================

class DeveloperModel {
  final String name;
  final String role;
  final String image;
  final String phone;
  final String email;
  final String telegram;
  final String website;
  final String about;
  final Color color;
  final List<String> skills;

  DeveloperModel({
    required this.name,
    required this.role,
    required this.image,
    required this.phone,
    required this.email,
    required this.telegram,
    required this.website,
    required this.about,
    required this.color,
    this.skills = const [],
  });
}