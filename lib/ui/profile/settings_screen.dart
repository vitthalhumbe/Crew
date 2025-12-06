import 'package:flutter/material.dart';
import 'package:testing/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/edit_profile_screen.dart';
// ADD IMPORTS AT TOP
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'notification_settings.dart';
import 'edit_profile_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  // ------------------ LOAD THEME FROM STORAGE ------------------
  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("app_theme_dark") ?? false;
    });
  }

  // ------------------ SAVE THEME ------------------
  Future<void> saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("app_theme_dark", value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const SizedBox(height: 10),

          // ACCOUNT SECTION
          const _SectionHeader("ACCOUNT SETTINGS"),

          _SettingsTile(
  title: "Edit Profile",
  icon: Icons.edit,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(
        currentName: "", 
        currentBio: "", 
        currentAvatarUrl: "",
      )),
    );
  },
),


          const SizedBox(height: 20),

          // GENERAL SECTION
          const _SectionHeader("GENERAL"),

          _SettingsTile(
  title: "Notification Settings",
  icon: Icons.notifications,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationSettingsScreen(),
      ),
    );
  },
),


          _SettingsTile(
  title: "Light Theme",
  icon: Icons.light_mode,
  onTap: () {
    Provider.of<ThemeProvider>(context, listen: false)
        .setTheme(ThemeMode.light);
  },
),

_SettingsTile(
  title: "Dark Theme",
  icon: Icons.dark_mode,
  onTap: () {
    Provider.of<ThemeProvider>(context, listen: false)
        .setTheme(ThemeMode.dark);
  },
),

_SettingsTile(
  title: "System Theme",
  icon: Icons.phone_android,
  onTap: () {
    Provider.of<ThemeProvider>(context, listen: false)
        .setTheme(ThemeMode.system);
  },
),


          const SizedBox(height: 20),

          // SUPPORT SECTION
          const _SectionHeader("SUPPORT"),

          _SettingsTile(
  title: "Privacy Policy",
  icon: Icons.privacy_tip,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  },
),

          _SettingsTile(
  title: "About",
  icon: Icons.info_outline,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutScreen(),
      ),
    );
  },
),
        ],
      ),
    );
  }
}

// ---------------- WIDGETS -------------------

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.6),
          ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurface),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
