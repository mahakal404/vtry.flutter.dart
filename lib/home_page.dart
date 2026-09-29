import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_page.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Safety check: Handling null if Firebase is not initialized
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: (user?.photoURL != null) 
              ? NetworkImage(user!.photoURL!) 
              : const AssetImage('assets/app_logo.png') as ImageProvider,
          ),
          const SizedBox(height: 10),
          Text(
            "Welcome, ${user?.displayName ?? 'User'} 👋", 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
          ),
          Text(
            user?.email ?? "No email found", 
            style: const TextStyle(color: Colors.grey)
          ),
          const Divider(height: 40),
          _infoTile(Icons.height, "Height", "175 cm"),
          _infoTile(Icons.accessibility, "Body Type", "Athletic"),
          _infoTile(Icons.straighten, "Preferred Size", "L"),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}