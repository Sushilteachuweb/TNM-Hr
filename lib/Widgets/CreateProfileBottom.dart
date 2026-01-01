import 'package:flutter/material.dart';

class CreateProfileBottom extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const CreateProfileBottom({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Choose Option",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text("Take Photo"),
            onTap: onCameraTap,
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blue),
            title: const Text("Choose from Gallery"),
            onTap: onGalleryTap,
          ),
        ],
      ),
    );
  }
}
