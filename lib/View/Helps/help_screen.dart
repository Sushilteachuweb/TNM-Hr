import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../bottomNavBar/bottomNavBar.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I post a new job?',
      'answer':
          'To post a new job, go to the Dashboard and click on "Post New Job" button. Fill in all the required details and submit.',
    },
    {
      'question': 'How can I manage job applications?',
      'answer':
          'You can view and manage applications by clicking on "View Applicants" button on any job card in the Jobs section.',
    },
    {
      'question': 'How do I edit my profile?',
      'answer':
          'Go to Profile section and click on the edit icon in the top right corner to update your information.',
    },
    {
      'question': 'What are job credits?',
      'answer':
          'Job credits are used to post jobs. You can purchase more credits from the Dashboard or contact support.',
    },
    {
      'question': 'How do I contact support?',
      'answer':
          'You can contact our support team through the contact form below or email us at support@thenaukrimitra.com | thenaukrimitra@gmail.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () {
            // Navigate to home screen instead of going back
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavBar(initialIndex: 0),
              ),
            );
          },
        ),
        title: Text(
          "Help & Support",
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildFAQsSection(),
            const SizedBox(height: 24),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Column(
        children: [
          const Icon(Icons.help_outline_rounded, size: 50, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            "How can we help you?",
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Contact our support team for assistance",
            style: AppTextStyles.body2.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: AppTextStyles.h4),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.email_outlined,
                title: "Email Support",
                subtitle: "Send us an email",
                onTap: () => _launchEmail(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.phone_outlined,
                title: "Call Support",
                subtitle: "Speak with agent",
                onTap: () => _launchPhone(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Frequently Asked Questions", style: AppTextStyles.h4),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppColors.cardShadow],
          ),
          child: Column(
            children: _faqs.map((faq) {
              return ExpansionTile(
                title: Text(
                  faq['question'],
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(faq['answer'], style: AppTextStyles.body2),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Contact Us", style: AppTextStyles.h4),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppColors.cardShadow],
          ),
          child: Column(
            children: [
              _buildContactInfo(
                icon: Icons.email_outlined,
                title: "Email",
                subtitle: "support@thenaukrimitra.com | thenaukrimitra@gmail.com",
                onTap: () => _launchEmail(),
              ),
              const SizedBox(height: 16),
              _buildContactInfo(
                icon: Icons.phone_outlined,
                title: "Phone",
                subtitle: "01169268088",
                onTap: () => _launchPhone(),
              ),
              const SizedBox(height: 16),
              _buildContactInfo(
                icon: Icons.location_on_outlined,
                title: "Address",
                subtitle: "D9, Ground Floor, Sector 3, Noida, Uttar Pradesh – 201301",
                onTap: () => _launchMaps(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.body2),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textHint,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for launching external apps
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@thenaukrimitra.com',
      query: 'subject=Support Request&body=Hello, I need help with...',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorSnackBar('Could not launch email app');
      }
    } catch (e) {
      _showErrorSnackBar('Unable to open email app');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '01169268088');
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackBar('Could not launch phone app');
      }
    } catch (e) {
      _showErrorSnackBar('Unable to open phone app');
    }
  }

  Future<void> _launchMaps() async {
    final String address = "D9, Ground Floor, Sector 3, Noida, Uttar Pradesh 201301";
    final Uri mapsUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      query: 'api=1&query=${Uri.encodeComponent(address)}',
    );
    
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not launch maps');
      }
    } catch (e) {
      _showErrorSnackBar('Unable to open maps');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
