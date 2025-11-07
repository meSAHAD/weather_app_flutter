import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/welcome.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'My Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (user != null) _buildProfileSection(user),
                    const SizedBox(height: 30),
                    _buildMenuList(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(User user) {
    final creationDate = user.metadata.creationTime;
    final formattedDate = creationDate != null
        ? DateFormat('MMMM yyyy').format(creationDate)
        : 'N/A';

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white.withOpacity(0.9),
          child: Text(
            user.email?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.email ?? 'No email available',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Member since $formattedDate',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // Placeholder for navigation
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Log Out',
            isLogout: true,
            onTap: () async {
              // The StreamBuilder in main.dart will handle navigation
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final color = isLogout ? Colors.redAccent : Colors.white;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: isLogout
          ? null
          : Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
      onTap: onTap,
    );
  }
}
