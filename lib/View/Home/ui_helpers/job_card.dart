import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String salary;
  final String location;
  final String posted;
  final bool active;
  final int applicants;

  const JobCard({
    super.key,
    required this.title,
    required this.salary,
    required this.location,
    required this.posted,
    required this.active,
    required this.applicants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (active)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0XFF1F64A6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      applicants.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 4),
          Text(salary,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              )),
          const SizedBox(height: 4),
          Text(location,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              )),
          const SizedBox(height: 4),
          Text(posted,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              )),
        ],
      ),
    );
  }
}
