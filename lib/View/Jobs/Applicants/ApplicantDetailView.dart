import 'package:flutter/material.dart';

class ApplicantDetailView extends StatefulWidget {
  const ApplicantDetailView({super.key});

  @override
  State<ApplicantDetailView> createState() => _ApplicantDetailViewState();
}

class _ApplicantDetailViewState extends State<ApplicantDetailView> {
  int currentApplicantIndex = 0;

  final List<Map<String, dynamic>> applicants = [
    {
      'name': 'Dhaaaarnaaa',
      'role': 'Development',
      'appliedDate': '9/8/2025',
      'salary': '₹50000 /month',
      'education': 'B.Tech',
      'gender': 'Male',
      'location': '-',
      'skills': 'Testing, Python',
      'experience': '2 years',
      'email': 'jjdhjdhjd@gmail.com',
      'languages': '',
    },
    {
      'name': 'John Doe',
      'role': 'Design',
      'appliedDate': '10/8/2025',
      'salary': '₹45000 /month',
      'education': 'M.Tech',
      'gender': 'Male',
      'location': 'Delhi',
      'skills': 'UI/UX, Figma',
      'experience': '3 years',
      'email': 'john.doe@example.com',
      'languages': 'English, Hindi',
    },
    {
      'name': 'Jane Smith',
      'role': 'Marketing',
      'appliedDate': '11/8/2025',
      'salary': '₹40000 /month',
      'education': 'MBA',
      'gender': 'Female',
      'location': 'Mumbai',
      'skills': 'SEO, Content Writing',
      'experience': '1 year',
      'email': 'jane.smith@example.com',
      'languages': 'English, Hindi',
    },
  ];

  void _navigateApplicant(int direction) {
    setState(() {
      if (direction == -1 && currentApplicantIndex > 0) {
        currentApplicantIndex--;
      } else if (direction == 1 &&
          currentApplicantIndex < applicants.length - 1) {
        currentApplicantIndex++;
      }
    });
  }

  void _showNumber() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Phone Number"),
        content: const Text("1234567890"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _messageApplicant() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Opening WhatsApp..."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _inviteForInterview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Interview invitation sent!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final applicant = applicants[currentApplicantIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Applicant Details",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildApplicantCard(applicant),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          _buildNavigationArrows(),
          _buildActionButtons(applicant),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> applicant) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[100],
                child: Icon(Icons.person, size: 45, color: Colors.grey[400]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            applicant['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          "Applied on: ${applicant['appliedDate']}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F64A6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        applicant['role'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  const Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: Colors.green,
                  ),
                  applicant['salary'],
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  const Icon(Icons.school, size: 16, color: Color(0xFF1F64A6)),
                  applicant['education'],
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  const Icon(Icons.male, size: 16, color: Colors.blue),
                  applicant['gender'],
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.black54,
                  ),
                  applicant['location'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildDetailRow("Skills", applicant['skills']),
          const SizedBox(height: 10),
          _buildDetailRow("Work Experience", "${applicant['experience']}"),
          const SizedBox(height: 10),
          _buildDetailRow("Email", applicant['email']),
          const SizedBox(height: 10),
          _buildDetailRow(
            "Languages",
            applicant['languages'].isEmpty ? '-' : applicant['languages'],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(Widget icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationArrows() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: currentApplicantIndex > 0
                  ? () => _navigateApplicant(-1)
                  : null,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: currentApplicantIndex > 0
                      ? Colors.black87
                      : Colors.grey[400],
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: currentApplicantIndex < applicants.length - 1
                  ? () => _navigateApplicant(1)
                  : null,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: currentApplicantIndex < applicants.length - 1
                      ? Colors.black87
                      : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> applicant) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showNumber,
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text("Show Number"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _messageApplicant,
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text("Message"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _inviteForInterview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Invited for Interview"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
