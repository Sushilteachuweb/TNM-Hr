import 'package:flutter/material.dart';

class ApplicantDetails extends StatelessWidget {
  const ApplicantDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Skills"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _ChipText("SEO"),
              _ChipText("Social Media"),
              _ChipText("Digital Campaigns"),
              _ChipText("Google Analytics"),
              _ChipText("Google AdWords"),
            ],
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Asset"),
          const Text(
            "✔ Internet Connection, Laptop/Desktop, 1 more",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Documents"),
          const Text(
            "📄 Bank Account, Aadhar Card, 1 more",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Work Experience"),
          const Text(
            "• 2 Years & 6 Months in Digital Marketing\n   at Hex Business Innovations",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _ChipText extends StatelessWidget {
  final String text;
  const _ChipText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }
}
