import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class VTryPage extends StatefulWidget {
  const VTryPage({super.key});
  @override
  State<VTryPage> createState() => _VTryPageState();
}

class _VTryPageState extends State<VTryPage> {
  XFile? _userImage;
  XFile? _clothImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isUser) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          if (isUser) {
            _userImage = pickedFile;
          } else {
            _clothImage = pickedFile;
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("V-Try", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1A237E))),
            const Text("Virtual Try-On Experience", style: TextStyle(fontSize: 14, color: Colors.grey)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    _buildUploadCard(
                      isDark: isDark, 
                      title: "Upload Your Image", 
                      subtitle: "Add a photo of yourself", 
                      imageFile: _userImage, 
                      icon: Icons.person_outline, 
                      iconColor: const Color(0xFF5C6BC0), 
                      circleBg: isDark ? Colors.white10 : const Color(0xFFF1F3FF), 
                      onTap: () => _pickImage(true), 
                      onClear: () => setState(() => _userImage = null)
                    ),
                    const SizedBox(height: 20),
                    _buildUploadCard(
                      isDark: isDark, 
                      title: "Upload Your Cloth", 
                      subtitle: "Add a clothing item image", 
                      imageFile: _clothImage, 
                      icon: Icons.checkroom, 
                      iconColor: const Color(0xFFEC407A), 
                      circleBg: isDark ? Colors.white10 : const Color(0xFFFFF1F6), 
                      onTap: () => _pickImage(false), 
                      onClear: () => setState(() => _clothImage = null)
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(isDark),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            _buildTryOnButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({required bool isDark, required String title, required String subtitle, XFile? imageFile, required IconData icon, required Color iconColor, required Color circleBg, required VoidCallback onTap, required VoidCallback onClear}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03), blurRadius: 20, offset: const Offset(0, 10))]),
        child: Column(children: [
          if (imageFile != null) Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(15), child: kIsWeb ? Image.network(imageFile.path, height: 150, width: 150, fit: BoxFit.cover) : Image.file(File(imageFile.path), height: 150, width: 150, fit: BoxFit.cover)), Positioned(right: 0, top: 0, child: GestureDetector(onTap: onClear, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 20))))])
          else CircleAvatar(radius: 35, backgroundColor: circleBg, child: Icon(icon, size: 40, color: iconColor)),
          const SizedBox(height: 20), Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A237E))),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(border: Border.all(color: isDark ? Colors.white24 : Colors.black12), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.file_upload_outlined, size: 20, color: iconColor), const SizedBox(width: 8), Text(imageFile == null ? "Choose Photo" : "Change Photo", style: TextStyle(fontWeight: FontWeight.bold, color: iconColor))])),
        ]),
      ),
    );
  }

  Widget _buildTryOnButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8C9EFF), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: (_userImage != null && _clothImage != null && !_isLoading) ? () async {
          setState(() => _isLoading = true);
          
          // LightX API Call
          final result = await ApiService().generateTryOn(_userImage!, _clothImage!);
          
          setState(() => _isLoading = false);

          if (result['success'] == true) {
            _showResultDialog(result['url']); 
          } else {
            // Display the specific error message from ApiService
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['error'] ?? "Try-On Failed. Please check credits or internet."),
                  backgroundColor: Colors.redAccent,
                )
              );
            }
          }
        } : null,
        icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.checkroom, color: Colors.white),
        label: Text(_isLoading ? "Generating..." : "Try On", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // --- बदला हुआ रिज़ल्ट डायलॉग (Image.network के साथ) ---
  void _showResultDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("New Look!", style: TextStyle(color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            // LightX से मिले URL को यहाँ दिखाया जाएगा
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl, 
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Text("Could not load image. Try again."),
              ),
            ),
            const SizedBox(height: 10), 
            const Text("Looking good!", style: TextStyle(color: Colors.black54))
          ]
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Awesome!")
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: isDark ? Colors.green.withValues(alpha: 0.1) : const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.shield_outlined, color: Colors.green, size: 20), const SizedBox(width: 10), Text("Your Privacy Matters", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.greenAccent : Colors.green))]), const SizedBox(height: 10), Text("Your images are processed securely and are never stored.", style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF1B5E20), height: 1.5))]));
  }
}