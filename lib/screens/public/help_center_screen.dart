// ==========================================================
// FILE: lib/screens/public/help_center_screen.dart
// HELP CENTER / SUPPORT / FAQ - ENHANCED VERSION
// Professional UI with Animations & Full Language Support
// ==========================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    super.dispose();
  }

  String tr(String en, String am, String om, String code) {
    if (code == "am") return am;
    if (code == "om") return om;
    return en;
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      _showSnackbar("Could not launch phone dialer");
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showSnackbar("Could not launch email client");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Map<String, String>> getFilteredFaqs(String code, String query) {
    final allFaqs = [
      {
        "q": tr(
          "How to scan coffee leaf?",
          "የቡና ቅጠል እንዴት እንደሚቃኝ?",
          "Akkaataa baala bunaa itti sakatta'an?",
          code,
        ),
        "a": tr(
          "1. Tap the camera icon on home screen\n2. Take a clear photo of a coffee leaf\n3. Wait 2-3 seconds for AI analysis\n4. View detailed results and recommendations\n\n💡 Tip: Use natural lighting and avoid shadows for best results.",
          "1. በዋና ገጹ ላይ የካሜራ አዶን ይንኩ\n2. ግልጽ የሆነ የቡና ቅጠል ፎቶ ያንሱ\n3. ለ2-3 ሰከንዶች ይጠብቁ\n4. ዝርዝር ውጤቶችን እና ምክሮችን ይመልከቱ\n\n💡 ምክር: ለተሻለ ውጤት ተፈጥሯዊ ብርሃን ይጠቀሙ።",
          "1. Kaameraa tuqi\n2. Suuraa baala bunaa kaasi\n3. 2-3 sec eegi\n4. Bu'aa fi gorsa ilaali\n\n💡 Yaada: Ifa uumamaa fayyadami.",
          code,
        ),
        "icon": "📸",
        "category": "scanning",
      },
      {
        "q": tr(
          "Why detection fails?",
          "ለምን ምርመራ አይሳካም?",
          "Maaliif qorannoon hin milkaa'u?",
          code,
        ),
        "a": tr(
          "Common reasons for detection failure:\n\n❌ Poor lighting or shadows\n❌ Blurry or out-of-focus images\n❌ Non-coffee leaf (other plants)\n❌ Damaged or torn leaves\n❌ Background too cluttered\n\n✅ Solution: Use natural light, hold camera steady, and ensure the leaf is clean and clear.",
          "ለምርመራ ውድቀት የተለመዱ ምክንያቶች:\n\n❌ ደካማ ብርሃን ወይም ጥላ\n❌ ደብዛዛ ወይም ትኩረት ያልተሰጠው ፎቶ\n❌ ቡና ያልሆነ ቅጠል\n❌ የተበላሹ ቅጠሎች\n❌ የተጨናነቀ ጀርባ\n\n✅ መፍትሔ: ተፈጥሯዊ ብርሃን ይጠቀሙ፣ ካሜራዎን ያረጋጉ።",
          "Sababoonni qorannoo kufuu:\n\n❌ Ifa gadhee\n❌ Suuraa ifa hin qabne\n❌ Baala bunaa miti\n❌ Baala caccabee\n❌ Duuba walitti makamaa\n\n✅ Furmaata: Ifa uumamaa fayyadami.",
          code,
        ),
        "icon": "⚠️",
        "category": "troubleshooting",
      },
      {
        "q": tr(
          "How to improve accuracy?",
          "ትክክለኛነት እንዴት ይሻላል?",
          "Akkaataa sirrii taasisuu?",
          code,
        ),
        "a": tr(
          "Tips for better accuracy:\n\n🌞 Use natural daylight\n📱 Hold camera 10-15cm from leaf\n🎯 Focus on the leaf center\n🍃 Choose healthy-looking leaves\n🚫 Avoid wet or dirty leaves\n🔄 Scan multiple leaves for comparison\n\n📊 Our AI model has 95%+ accuracy when following these tips!",
          "ለተሻለ ትክክለኛነት ምክሮች:\n\n🌞 ተፈጥሯዊ የቀን ብርሃን ይጠቀሙ\n📱 ካሜራዎን ከቅጠል 10-15 ሴ.ሜ ያርቁ\n🎯 በቅጠሉ መሃል ላይ ያተኩሩ\n🍃 ጤናማ ቅጠሎችን ይምረጡ\n🚫 እርጥብ ወይም ቆሻሻ ቅጠሎችን ያስወግዱ\n🔄 ለማነጻጸር ብዙ ቅጠሎችን ይቃኙ",
          "Gorsa sirriif:\n\n🌞 Ifa guyyaa fayyadami\n📱 Kaameraa 10-15 cm fageessi\n🎯 Gidduu baala irratti xiyyeeffadhi\n🍃 Baala fayyaa qabu filadhi\n🚫 Baala jiise ykn xuroo ofirraa fageessi\n🔄 Baala hedduu sakatta'i",
          code,
        ),
        "icon": "🎯",
        "category": "tips",
      },
      {
        "q": tr(
          "What diseases can be detected?",
          "ምን በሽታዎች መለየት ይቻላል?",
          "Dhukkuboota maalii adda baasuu danda'a?",
          code,
        ),
        "a": tr(
          "CoffeeGuard detects these diseases:\n\n🟢 Coffee Leaf Rust (Hemileia vastatrix)\n🟡 Coffee Berry Disease (Colletotrichum kahawae)\n🟤 Coffee Wilt Disease (Fusarium xylarioides)\n⚪ Cercospora Leaf Spot\n🔵 American Leaf Spot\n🟣 Phoma Leaf Spot\n\n✅ Healthy leaves are also identified with confidence scores.",
          "ኮፊጋርድ የሚከተሉትን በሽታዎች ይለያል:\n\n🟢 የቡና ቅጠል ዝገት\n🟡 የቡና ፍሬ በሽታ\n🟤 የቡና ዊልት በሽታ\n⚪ ሰርኮስፖራ ቅጠል ነጠብጣብ\n🔵 አሜሪካዊ ቅጠል ነጠብጣብ\n🟣 ፎማ ቅጠል ነጠብጣብ",
          "CoffeeGuard dhukkuboota kanneen adda baasa:\n\n🟢 Dhukkuba Baala Buna\n🟡 Dhukkuba Firiirii Buna\n🟤 Dhukkuba Buna Wilt\n⚪ Cercospora Leaf Spot\n🔵 American Leaf Spot\n🟣 Phoma Leaf Spot",
          code,
        ),
        "icon": "🔬",
        "category": "features",
      },
      {
        "q": tr(
          "Is my data private and secure?",
          "ውሂቤ የግል እና ደህንነቱ የተጠበቀ ነው?",
          "Deetaan koo iccitii fi egdoma?",
          code,
        ),
        "a": tr(
          "🔒 Your privacy matters to us:\n\n✅ All scans are encrypted\n✅ We don't share data with third parties\n✅ Images are stored securely on Supabase\n✅ You can delete your history anytime\n✅ Expert reviews are anonymous\n\n📋 Read our full privacy policy in app settings.",
          "🔒 ግላዊነትዎ ለእኛ አስፈላጊ ነው:\n\n✅ ሁሉም ቅኝቶች ምስጠራ ናቸው\n✅ ውሂብን ከሶስተኛ ወገኖች ጋር አንጋራም\n✅ ምስሎች በሱፓቤዝ ላይ ደህንነታቸው ተጠብቆ ይቀመጣሉ\n✅ ታሪክዎን በማንኛውም ጊዜ መሰረዝ ይችላሉ",
          "🔒 Kophaakee barbaachisa:\n\n✅ Sakattaanni hundi iccitii\n✅ Deetaa namatti hin kennu\n✅ Suuraan Supabase irra egdoma\n✅ Seenaa keessan yeroo kamuu haquu danda'u",
          code,
        ),
        "icon": "🔒",
        "category": "privacy",
      },
      {
        "q": tr(
          "How to contact support?",
          "ድጋፍ እንዴት ማግኘት ይቻላል?",
          "Akkataa gargaarsa quunnamu?",
          code,
        ),
        "a": tr(
          "Get help through:\n\n📞 Call: +251 900 000 000\n📧 Email: support@coffeeguard.com\n💬 Live Chat (within app)\n📱 Telegram: @CoffeeGuard_Support\n🌐 Website: www.coffeeguard.com\n\n💡 Response time: Within 24 hours",
          "ድጋፍ የሚከተሉት መንገዶች ያግኙ:\n\n📞 ይደውሉ: +251 900 000 000\n📧 ኢሜይል: support@coffeeguard.com\n💬 የቀጥታ ውይይት\n📱 ቴሌግራም: @CoffeeGuard_Support\n🌐 ድረገጽ: www.coffeeguard.com",
          "Gargaarsa kanaan argadhu:\n\n📞 Bilbilaa: +251 900 000 000\n📧 Email: support@coffeeguard.com\n💬 Live Chat\n📱 Telegram: @CoffeeGuard_Support\n🌐 Website: www.coffeeguard.com",
          code,
        ),
        "icon": "📞",
        "category": "support",
      },
      {
        "q": tr(
          "Is CoffeeGuard free to use?",
          "ኮፊጋርድ በነጻ መጠቀም ይቻላል?",
          "CoffeeGuard bilisaadhaan fayyadamuu danda'a?",
          code,
        ),
        "a": tr(
          "💰 CoffeeGuard is currently FREE for all Ethiopian farmers!\n\n✅ Free unlimited scans\n✅ Free disease detection\n✅ Free expert recommendations\n✅ No hidden fees\n✅ No subscription required\n\n🌟 We're committed to helping Ethiopian coffee farmers protect their crops.",
          "💰 ኮፊጋርድ በአሁኑ ጊዜ ለኢትዮጵያ አርሶ አደሮች በነጻ ነው!\n\n✅ ያልተገደበ ቅኝት\n✅ ነጻ የበሽታ መለየት\n✅ ነጻ የባለሙያ ምክሮች\n✅ ምንም ድብቅ ክፍያዎች የሉም",
          "💰 CoffeeGuard ammaaf Qonnaan Bultootiif BILISA!\n\n✅ Sakattaannii daangaa hin qabne\n✅ Addabbiin bilisa\n✅ Gorsi bilisa",
          code,
        ),
        "icon": "💰",
        "category": "pricing",
      },
      {
        "q": tr(
          "How to get expert consultation?",
          "የባለሙያ ማማከር እንዴት ማግኘት ይቻላል?",
          "Akkataa marii hayyuu argachuu?",
          code,
        ),
        "a": tr(
          "Expert consultation options:\n\n👨‍🌾 Free: Submit scan for expert review\n👩‍🔬 Premium: Video call with expert (\$5/session)\n📞 Phone consultation (free for farmers)\n💬 Chat with experts (in-app messaging)\n\n🎓 All Ethiopian farmers get FREE basic consultation!",
          "የባለሙያ ማማከር አማራጮች:\n\n👨‍🌾 ነጻ: ለባለሙያ ግምገማ ቅኝት ያስገቡ\n👩‍🔬 ክፍያ: ከባለሙያ ጋር የቪዲዮ ጥሪ\n📞 የስልክ ማማከር\n💬 ከባለሙያዎች ጋር ውይይት",
          "Filannoon marii hayyuuti:\n\n👨‍🌾 Bilisa: Hayyuuf ergi\n👩‍🔬 Kaffaltii: Bilbilaa Vidiyoo\n📞 Bilbilaa\n💬 Marii hayyuutiin",
          code,
        ),
        "icon": "👨‍🌾",
        "category": "consultation",
      },
    ];

    if (query.isEmpty) return allFaqs;

    return allFaqs.where((faq) {
      final question = faq["q"]!.toLowerCase();
      final answer = faq["a"]!.toLowerCase();
      final category = faq["category"]!.toLowerCase();
      final search = query.toLowerCase();
      return question.contains(search) ||
          answer.contains(search) ||
          category.contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final code = lang.code;
    final isDark = theme.currentTheme == AppThemeMode.dark;

    final filteredFaqs = getFilteredFaqs(code, _searchQuery);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          tr("Help Center", "የእርዳታ ማዕከል", "Gargaarsa", code),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () {
              _sendEmail("support@coffeeguard.com");
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
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
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: tr(
                        "Search questions...",
                        "ጥያቄዎችን ይፈልጉ...",
                        "Gaaffii barbaadi...",
                        code,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Hero Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade700,
                      Colors.green.shade500,
                      Colors.green.shade300,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.support_agent,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr(
                        "How can we help you today?",
                        "ዛሬ እንዴት ልንረዳዎ እንችላለን?",
                        "Har'a akkaataa itti si gargaaru?",
                        code,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr(
                        "Find answers to common questions",
                        "የተለመዱ ጥያቄዎች መልስ ያግኙ",
                        "Deebisaaf gaaffii beekkamoo argadhu",
                        code,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // FAQ Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr(
                        "Frequently Asked Questions",
                        "ተደጋጋሚ ጥያቄዎች",
                        "Gaaffiiwwan Beekkamoo",
                        code,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${filteredFaqs.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // FAQ List
              Expanded(
                child: filteredFaqs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              tr(
                                "No results found",
                                "ምንም ውጤት አልተገኘም",
                                "Bu'aan hin argamne",
                                code,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tr(
                                "Try a different search term",
                                "የተለየ የፍለጋ ቃል ይሞክሩ",
                                "Jecha biraa barbaadi",
                                code,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredFaqs.length,
                        itemBuilder: (context, index) {
                          final faq = filteredFaqs[index];
                          return _FAQCard(
                            question: faq["q"]!,
                            answer: faq["a"]!,
                            icon: faq["icon"]!,
                            isDark: isDark,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: Icons.phone,
                  label: tr("Call", "ደውል", "Bilbilaa", code),
                  color: Colors.green,
                  onTap: () => _makeCall("+251916225842"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactButton(
                  icon: Icons.email,
                  label: tr("Email", "ኢሜይል", "Email", code),
                  color: Colors.blue,
                  onTap: () => _sendEmail("peterhope935@gmail.com"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactButton(
                  icon: Icons.chat,
                  label: tr("Live Chat", "ውይይት", "Chat", code),
                  color: Colors.orange,
                  onTap: () {
                    _showSnackbar("Live chat coming soon!");
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

// ==========================================================
// FAQ CARD
// ==========================================================

class _FAQCard extends StatefulWidget {
  final String question;
  final String answer;
  final String icon;
  final bool isDark;

  const _FAQCard({
    required this.question,
    required this.answer,
    required this.icon,
    required this.isDark,
  });

  @override
  State<_FAQCard> createState() => __FAQCardState();
}

class __FAQCardState extends State<_FAQCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Text(
            widget.question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white : Colors.black87,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.green,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF2C2C2C)
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.answer,
                      style: TextStyle(
                        color: widget.isDark ? Colors.grey.shade300 : Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.thumb_up, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Was this helpful?",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Yes",
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "No",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ==========================================================
// CONTACT BUTTON
// ==========================================================

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}