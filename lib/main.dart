import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MTAlchemyApp());
}


const Color navy = Color(0xFF0B1426);
const Color blue = Color(0xFF172B4D);
const Color yellow = Color(0xFFD8B56D);
// Legacy accent name retained so existing widgets keep working; now uses the brand gold.
const Color purple = Color(0xFFD8B56D);
const Color pageBg = Color(0xFFF4F2ED);

class MTAlchemyApp extends StatelessWidget {
  const MTAlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MT Alchemy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: yellow,
          brightness: Brightness.light,
          primary: navy,
          secondary: yellow,
          surface: Colors.white,
        ),
        fontFamily: 'Arial',
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: navy.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE8E2D5)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFAF9F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD8D3C8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD8D3C8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: navy, width: 1.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            animationDuration: const Duration(milliseconds: 220),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            animationDuration: const Duration(milliseconds: 220),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
      home: const MainWebsite(),
    );
  }
}

class Course {
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final Color color;

  const Course(
      this.title,
      this.category,
      this.description,
      this.icon,
      this.color,
      );
}

class Product {
  final String title;
  final String description;
  final String price;
  final IconData icon;
  final Color color;

  const Product(
      this.title,
      this.description,
      this.price,
      this.icon,
      this.color,
      );
}

const List<Course> courses = [
  Course(
    'Leadership Essentials',
    'Leadership',
    'Build confidence, communication and leadership skills.',
    Icons.groups_rounded,
    navy,
  ),
  Course(
    'Digital Transformation',
    'Digital Skills',
    'Understand modern digital tools and business transformation.',
    Icons.devices_rounded,
    purple,
  ),
  Course(
    'Workplace Communication',
    'Professional Skills',
    'Improve teamwork, communication and collaboration.',
    Icons.forum_rounded,
    blue,
  ),
  Course(
    'Project Management',
    'Business',
    'Learn planning, delivery and project coordination.',
    Icons.task_alt_rounded,
    Color(0xFF168A79),
  ),
];

const List<Product> products = [
  Product(
    'Digital Learning Guide',
    'A practical guide for professional development.',
    'RM 29.00',
    Icons.menu_book_rounded,
    purple,
  ),
  Product(
    'Leadership Workbook',
    'Exercises and activities for developing leaders.',
    'RM 39.00',
    Icons.auto_stories_rounded,
    navy,
  ),
  Product(
    'Corporate Training Pack',
    'Resources for team learning and development.',
    'RM 59.00',
    Icons.inventory_2_rounded,
    blue,
  ),
];

class MainWebsite extends StatefulWidget {
  const MainWebsite({super.key});

  @override
  State<MainWebsite> createState() => _MainWebsiteState();
}

class _MainWebsiteState extends State<MainWebsite> {
  String currentPage = 'Home';
  String signedInRole = 'Individual';
  final List<Product> cart = [];

  void navigate(String page) {
    setState(() => currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <String, Widget>{
      'Home': HomePage(
        onNavigate: navigate,
      ),
      'About Us': AboutPage(),
      'Services': ServicesPage(
        onNavigate: navigate,
      ),
      'Learning Hub': LearningPage(
        onNavigate: navigate,
      ),
      'Digital Store': StorePage(
        cart: cart,
        onAdd: (product) {
          setState(() => cart.add(product));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.title} added to your cart'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onCart: () => navigate('Cart'),
      ),
      'Cart': CartPage(
        cart: cart,
        onRemove: (index) {
          setState(() => cart.removeAt(index));
        },
        onShop: () => navigate('Digital Store'),
        onCheckout: () => navigate('Login'),
      ),
      'Login': LoginPage(
        onRegister: () => navigate('Register'),
        onLoginSuccess: (role) {
          setState(() {
            signedInRole = role;
            currentPage = 'Dashboard';
          });
        },
      ),
      'Register': RegisterPage(
        onLogin: () => navigate('Login'),
      ),
      'Dashboard': DashboardPage(
        role: signedInRole,
        onNavigate: navigate,
        onSignOut: () async {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          setState(() {
            signedInRole = 'Individual';
            currentPage = 'Home';
          });
        },
      ),
      'Contact': const ContactPage(),
    };

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 24,
        title: InkWell(
          onTap: () => navigate('Home'),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: purple, size: 30),
              SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MT ALCHEMY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'LEARN • GROW • TRANSFORM',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: yellow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width > 850)
            ...[
              'Home',
              'About Us',
              'Services',
              'Learning Hub',
              'Digital Store',
              if (FirebaseAuth.instance.currentUser != null) 'Dashboard',
              'Contact',
            ].map(
                  (page) => TextButton(
                onPressed: () => navigate(page),
                child: Text(
                  page,
                  style: TextStyle(
                    color: currentPage == page ? yellow : Colors.white,
                    fontWeight: currentPage == page
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Shopping cart',
            onPressed: () => navigate('Cart'),
            icon: Badge(
              label: Text('${cart.length}'),
              isLabelVisible: cart.isNotEmpty,
              child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 4),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
              ),
              onPressed: () => navigate('Login'),
              child: const Text('Sign in'),
            ),
          ),
        ],
      ),
      drawer: MediaQuery.sizeOf(context).width <= 850
          ? Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const ListTile(
                leading: Icon(Icons.auto_awesome, color: purple),
                title: Text(
                  'MT ALCHEMY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              for (final page in [
                'Home',
                'About Us',
                'Services',
                'Learning Hub',
                'Digital Store',
                'Cart',
                if (FirebaseAuth.instance.currentUser != null) 'Dashboard',
                'Contact',
                'Login',
              ])
                ListTile(
                  leading: Icon(_pageIcon(page)),
                  title: Text(page),
                  selected: currentPage == page,
                  onTap: () {
                    Navigator.pop(context);
                    navigate(page);
                  },
                ),
            ],
          ),
        ),
      )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(currentPage),
          child: pages[currentPage] ?? pages['Home']!,
        ),
      ),
    );
  }

  IconData _pageIcon(String page) {
    switch (page) {
      case 'Home':
        return Icons.home_outlined;
      case 'About Us':
        return Icons.info_outline;
      case 'Services':
        return Icons.business_center_outlined;
      case 'Learning Hub':
        return Icons.school_outlined;
      case 'Digital Store':
        return Icons.storefront_outlined;
      case 'Cart':
        return Icons.shopping_cart_outlined;
      case 'Contact':
        return Icons.mail_outline;
      case 'Dashboard':
        return Icons.dashboard_outlined;
      default:
        return Icons.login;
    }
  }
}

class FloatingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;

  const FloatingIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -7, end: 7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      child: Icon(widget.icon, size: widget.size, color: widget.color),
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _floatAnimation.value),
        child: child,
      ),
    );
  }
}

// -------------------- HOME PAGE --------------------

class HomePage extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 600 ? 22.0 : 64.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: width < 600 ? 45 : 76,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [navy, blue, Color(0xFF263A5A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Wrap(
              spacing: 40,
              runSpacing: 35,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: width < 600 ? width - 44 : 520,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          'YOUR PARTNER IN LEARNING & GROWTH',
                          style: TextStyle(
                            color: yellow,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Unlock Your Potential.\nTransform Your Future.',
                        style: TextStyle(
                          fontSize: 42,
                          height: 1.17,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Discover learning experiences, professional development '
                            'programmes and digital resources designed to help '
                            'individuals and organisations grow.',
                        style: TextStyle(
                          color: Color(0xFFE4E9F6),
                          height: 1.8,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: yellow,
                              foregroundColor: navy,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                            ),
                            onPressed: () => onNavigate('Learning Hub'),
                            child: const Text('Explore Learning'),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                            ),
                            onPressed: () => onNavigate('Contact'),
                            child: const Text('Contact Us'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: width < 600 ? width - 44 : 330,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Column(
                    children: [
                      FloatingIcon(
                        icon: Icons.auto_awesome,
                        size: 75,
                        color: yellow,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Learning that creates impact',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 23,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Build knowledge. Develop skills. Make a difference.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 45),
          const SectionHeading(
            eyebrow: 'WHAT WE OFFER',
            title: 'Everything you need to grow',
            subtitle:
            'Explore learning opportunities and resources for your next step.',
          ),
          const SizedBox(height: 28),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                FeatureCard(
                  icon: Icons.school_rounded,
                  title: 'Online Learning',
                  description:
                  'Explore courses and develop practical professional skills.',
                  color: navy,
                  onTap: () => onNavigate('Learning Hub'),
                ),
                FeatureCard(
                  icon: Icons.shopping_bag_rounded,
                  title: 'Digital Store',
                  description:
                  'Discover digital learning materials and useful resources.',
                  color: purple,
                  onTap: () => onNavigate('Digital Store'),
                ),
                FeatureCard(
                  icon: Icons.apartment_rounded,
                  title: 'Corporate Training',
                  description:
                  'Find learning solutions designed for organisations and teams.',
                  color: const Color(0xFF168A79),
                  onTap: () => onNavigate('Services'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          const SectionHeading(
            eyebrow: 'FEATURED COURSES',
            title: 'Learning for your next chapter',
            subtitle: 'Start exploring our sample learning catalogue.',
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: courses.take(3).map((course) {
                return CourseCard(
                  course: course,
                  onTap: () => onNavigate('Learning Hub'),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 45),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: 42,
            ),
            color: const Color(0xFFF3E7C8),
            child: Wrap(
              spacing: 25,
              runSpacing: 20,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const SizedBox(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to take the next step?',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 27,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Explore learning programmes or talk to us about '
                            'your organisation’s training needs.',
                        style: TextStyle(height: 1.7),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.all(20),
                  ),
                  onPressed: () => onNavigate('Contact'),
                  child: const Text('Get in Touch'),
                ),
              ],
            ),
          ),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- ABOUT PAGE --------------------

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  final List<Map<String, dynamic>> values = [
    {
      'icon': Icons.lightbulb_outline,
      'title': 'Innovation',
      'text': 'Encouraging new ideas and continuous improvement.',
    },
    {
      'icon': Icons.handshake_outlined,
      'title': 'Collaboration',
      'text': 'Supporting people and organisations to grow together.',
    },
    {
      'icon': Icons.trending_up,
      'title': 'Growth',
      'text': 'Building skills and creating meaningful learning outcomes.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const PageBanner(
            title: 'About MT Alchemy',
            subtitle:
            'Supporting learning, professional development and organisational growth.',
          ),
          const SizedBox(height: 42),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Learning with purpose',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 29,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MT Alchemy is presented here as a corporate learning '
                        'and development platform. The website brings learning '
                        'resources, training services and digital products into '
                        'one accessible experience for individuals and organisations.',
                    style: TextStyle(height: 1.9, fontSize: 16),
                  ),
                  const SizedBox(height: 35),
                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: values.map((value) {
                      return FeatureCard(
                        icon: value['icon'] as IconData,
                        title: value['title'] as String,
                        description: value['text'] as String,
                        color: purple,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    'Our goal',
                    style: TextStyle(
                      color: navy,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Provide a central place to explore courses, access '
                        'resources and discover training opportunities. '
                        'Organisation-specific information can be added from '
                        'the official company profile.',
                    style: TextStyle(height: 1.8, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 45),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- SERVICES PAGE --------------------

class ServicesPage extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const ServicesPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const PageBanner(
            title: 'Our Services',
            subtitle:
            'Learning and development experiences for individuals and organisations.',
          ),
          const SizedBox(height: 35),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                ServiceCard(
                  icon: Icons.cast_for_education,
                  title: 'Learning Programmes',
                  text:
                  'Explore structured learning experiences and professional development.',
                ),
                ServiceCard(
                  icon: Icons.groups_2_outlined,
                  title: 'Corporate Training',
                  text:
                  'Plan training opportunities around organisational needs.',
                ),
                ServiceCard(
                  icon: Icons.analytics_outlined,
                  title: 'Learning Progress',
                  text:
                  'Support learning oversight and progress reporting for teams.',
                ),
                ServiceCard(
                  icon: Icons.devices_outlined,
                  title: 'Digital Resources',
                  text:
                  'Access digital materials that support learning and development.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              padding: const EdgeInsets.all(20),
            ),
            onPressed: () => onNavigate('Contact'),
            child: const Text('Enquire About Training'),
          ),
          const SizedBox(height: 45),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- LEARNING HUB --------------------

class LearningPage extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const LearningPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const PageBanner(
            title: 'Learning Hub',
            subtitle:
            'Explore courses designed to support personal and professional growth.',
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: courses.map((course) {
                return CourseCard(
                  course: course,
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        icon: Icon(course.icon, color: course.color, size: 40),
                        title: Text(course.title),
                        content: Text(
                          '${course.description}\n\n'
                              'This is a sample course. Course enrolment and lesson '
                              'access will be connected to the backend later.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Close'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              onNavigate('Login');
                            },
                            child: const Text('Sign in to continue'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 35),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- DIGITAL STORE --------------------

class StorePage extends StatelessWidget {
  final List<Product> cart;
  final ValueChanged<Product> onAdd;
  final VoidCallback onCart;

  const StorePage({
    super.key,
    required this.cart,
    required this.onAdd,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const PageBanner(
            title: 'Digital Store',
            subtitle:
            'Discover learning guides, workbooks and digital resources.',
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: products.map((product) {
                return Container(
                  width: 280,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE8E2D5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: product.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          product.icon,
                          size: 55,
                          color: product.color,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        product.title,
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(height: 1.6, color: Colors.black54),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        product.price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: purple,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: navy,
                          ),
                          onPressed: () => onAdd(product),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add to cart'),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 25),
          OutlinedButton.icon(
            onPressed: onCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text('View Cart (${cart.length})'),
          ),
          const SizedBox(height: 45),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- CART --------------------

class CartPage extends StatelessWidget {
  final List<Product> cart;
  final ValueChanged<int> onRemove;
  final VoidCallback onShop;
  final VoidCallback onCheckout;

  const CartPage({
    super.key,
    required this.cart,
    required this.onRemove,
    required this.onShop,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const PageBanner(
            title: 'Your Cart',
            subtitle: 'Review your selected digital learning resources.',
          ),
          const SizedBox(height: 30),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: cart.isEmpty
                  ? Column(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 75,
                    color: purple,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Explore the store to find learning resources.'),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onShop,
                    child: const Text('Browse Store'),
                  ),
                ],
              )
                  : Column(
                children: [
                  for (int i = 0; i < cart.length; i++)
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(
                          cart[i].icon,
                          color: cart[i].color,
                          size: 32,
                        ),
                        title: Text(cart[i].title),
                        subtitle: Text(cart[i].price),
                        trailing: IconButton(
                          tooltip: 'Remove item',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onRemove(i),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Checkout is a prototype screen. No real payment will be taken.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onCheckout,
                    child: const Text('Continue to Sign In'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 45),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- LOGIN PAGE --------------------


// -------------------- LOGIN PAGE --------------------

class LoginPage extends StatefulWidget {
  final VoidCallback onRegister;
  final ValueChanged<String> onLoginSuccess;

  const LoginPage({
    super.key,
    required this.onRegister,
    required this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;
  String selectedRole = 'Individual';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Firebase returned no signed-in user.');
      }

      final profileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!profileSnapshot.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'Your user profile was not found in Firestore. Please contact the administrator.',
        );
      }

      final profile = profileSnapshot.data() ?? <String, dynamic>{};
      final role = (profile['role'] ?? '').toString().trim();
      final status = (profile['status'] ?? 'Active').toString().trim();

      if (status.toLowerCase() != 'active') {
        await FirebaseAuth.instance.signOut();
        throw Exception('This account is not active. Please contact the administrator.');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful. Welcome ${user.email ?? ''}'),
        ),
      );
      widget.onLoginSuccess(
        ['Individual', 'Employer', 'Trainer', 'Super Admin'].contains(role)
            ? role
            : 'Individual',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          message = 'Invalid email or password.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;
        default:
          message = e.message ?? 'Sign-in failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8E2D5)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_person_outlined,
                  size: 55,
                  color: purple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue your learning journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),
                const Text('Account type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Individual',
                      child: Text('Individual'),
                    ),
                    DropdownMenuItem(
                      value: 'Employer',
                      child: Text('Employer'),
                    ),
                    DropdownMenuItem(
                      value: 'Trainer',
                      child: Text('Trainer'),
                    ),
                    DropdownMenuItem(
                      value: 'Super Admin',
                      child: Text('Super Admin'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 18),
                const Text('Email address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => hidePassword = !hidePassword);
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.all(18),
                  ),
                  onPressed: isLoading ? null : signIn,
                  child: isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Sign In'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: widget.onRegister,
                      child: const Text('Create account'),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'Sign in securely with your MT Alchemy account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// -------------------- ROLE-BASED DASHBOARD --------------------

class DashboardPage extends StatelessWidget {
  final String role;
  final ValueChanged<String> onNavigate;
  final VoidCallback onSignOut;

  const DashboardPage({
    super.key,
    required this.role,
    required this.onNavigate,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'Super Admin';
    final isEmployer = role == 'Employer';
    final isTrainer = role == 'Trainer';

    final title = isAdmin
        ? 'Administrator Dashboard'
        : isEmployer
        ? 'Employer Dashboard'
        : isTrainer
        ? 'Trainer Dashboard'
        : 'My Learning Dashboard';

    final subtitle = isAdmin
        ? 'Manage the MT Alchemy learning platform.'
        : isEmployer
        ? 'Explore learning solutions for your organisation.'
        : isTrainer
        ? 'Access learning resources and training tools.'
        : 'Continue your learning and discover new resources.';

    final items = <({IconData icon, String title, String description, String page})>[
      (
      icon: Icons.school_outlined,
      title: 'Learning Hub',
      description: 'Explore courses and professional learning resources.',
      page: 'Learning Hub',
      ),
      (
      icon: Icons.storefront_outlined,
      title: 'Digital Store',
      description: 'Browse digital guides, workbooks and resources.',
      page: 'Digital Store',
      ),
      (
      icon: Icons.business_center_outlined,
      title: 'Services',
      description: 'Discover training programmes and business services.',
      page: 'Services',
      ),
      (
      icon: Icons.mail_outline,
      title: 'Contact Support',
      description: 'Send an enquiry to the MT Alchemy team.',
      page: 'Contact',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [navy, blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: yellow.withValues(alpha: 0.45)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  runSpacing: 18,
                  children: [
                    SizedBox(
                      width: 650,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MT ALCHEMY  /  YOUR WORKSPACE',
                            style: TextStyle(
                              color: yellow,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: yellow.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: yellow.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              'Account role: $role',
                              style: const TextStyle(
                                color: yellow,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: onSignOut,
                      style: FilledButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: navy,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Quick access',
                style: TextStyle(
                  color: navy,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a section to continue.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 850
                      ? 4
                      : constraints.maxWidth >= 560
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 16) / columns;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: items.map((item) {
                      return SizedBox(
                        width: width,
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => onNavigate(item.page),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: yellow.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: navy,
                                      size: 27,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: navy,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Row(
                                    children: [
                                      Text(
                                        'Open section',
                                        style: TextStyle(
                                          color: navy,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: yellow,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              if (isAdmin) ...[
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined,
                            color: navy, size: 32),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Administrator access',
                                style: TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Your account is recognised as Super Admin. '
                                    'Administrative data-management tools must be '
                                    'connected to secured backend operations before use.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  height: 1.5,
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
              const SizedBox(height: 35),
              const SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- CONTACT PAGE --------------------

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const PageBanner(
            title: 'Contact Us',
            subtitle:
            'Tell us about your learning goals or corporate training needs.',
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 650),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE8E2D5)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Send us an enquiry',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null ||
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: messageController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'How can we help?',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value == null || value.trim().length < 10
                          ? 'Please enter at least 10 characters'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        padding: const EdgeInsets.all(18),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Form validated. Saving enquiries requires a backend.',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Submit Enquiry'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This prototype does not send or save your enquiry yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- REUSABLE WIDGETS --------------------

class PageBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageBanner({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [navy, blue, yellow],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: purple,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 285,
        transform: Matrix4.translationValues(0, _hovering ? -7 : 0, 0),
        child: Card(
          elevation: _hovering ? 9 : 0,
          shadowColor: widget.color.withValues(alpha: 0.18),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _hovering
                  ? widget.color.withValues(alpha: 0.35)
                  : const Color(0xFFE7EAF2),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(
                        alpha: _hovering ? 0.18 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(_hovering ? 19 : 15),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 28),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: Colors.black54,
                      height: 1.7,
                    ),
                  ),
                  if (widget.onTap != null) ...[
                    const SizedBox(height: 15),
                    const Row(
                      children: [
                        Text(
                          'Explore',
                          style: TextStyle(
                            color: purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, color: purple, size: 17),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 285,
        transform: Matrix4.translationValues(0, _hovering ? -7 : 0, 0),
        child: Card(
          elevation: _hovering ? 9 : 0,
          shadowColor: course.color.withValues(alpha: 0.18),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _hovering
                  ? course.color.withValues(alpha: 0.35)
                  : const Color(0xFFE5E8F0),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                height: 130,
                width: double.infinity,
                color: course.color.withValues(alpha: _hovering ? 0.17 : 0.10),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 240),
                  scale: _hovering ? 1.10 : 1.0,
                  child: Icon(course.icon, color: course.color, size: 55),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.category.toUpperCase(),
                      style: const TextStyle(
                        color: purple,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      course.description,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onTap,
                        child: const Text('View Course'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return FeatureCard(
      icon: icon,
      title: title,
      description: text,
      color: purple,
    );
  }
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D1C38),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
      child: const Column(
        children: [
          Icon(Icons.auto_awesome, color: yellow, size: 30),
          SizedBox(height: 12),
          Text(
            'MT ALCHEMY',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Learn • Grow • Transform',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 18),
          Text(
            'Corporate Learning & Development Platform',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          SizedBox(height: 10),
          Text(
            '© MT Alchemy — Prototype',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  final VoidCallback onLogin;

  const RegisterPage({
    super.key,
    required this.onLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = 'Individual';
  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    // Public sign-up is limited to non-administrator roles.
    const allowedRegistrationRoles = <String>{
      'Individual',
      'Employer',
      'Trainer',
    };
    if (!allowedRegistrationRoles.contains(selectedRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Super Admin accounts must be provisioned by an administrator.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = credential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'role': selectedRole,
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await user.updateDisplayName(nameController.text.trim());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! You can now sign in.'),
        ),
      );

      await navigateToLogin();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please sign in.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Choose a stronger password.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The account may have been created, but saving the profile failed. Check Firestore rules and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }





  Future<void> navigateToLogin() async {
    // Firebase automatically signs in the user after account creation.
    // Sign out so they can use the Sign In page normally.
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    widget.onLogin();
  }





  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8E2D5)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 52,
                  color: purple,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join MT Alchemy and start your learning journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                const Text('Full name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2DED4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: yellow,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Account type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2DED4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: yellow,
                        width: 2,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Individual',
                      child: Text('Individual'),
                    ),
                    DropdownMenuItem(
                      value: 'Employer',
                      child: Text('Employer'),
                    ),
                    DropdownMenuItem(
                      value: 'Trainer',
                      child: Text('Trainer'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Email address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => hidePassword = !hidePassword);
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Confirm password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Re-enter your password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.all(18),
                  ),
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}