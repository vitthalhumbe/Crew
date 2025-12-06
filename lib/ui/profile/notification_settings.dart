import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool generalNotif = true;
  bool taskNotif = true;
  bool reminderNotif = false;

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      generalNotif = prefs.getBool("notif_general") ?? true;
      taskNotif = prefs.getBool("notif_task") ?? true;
      reminderNotif = prefs.getBool("notif_reminder") ?? false;
    });
  }

  Future<void> savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("notif_general", generalNotif);
    prefs.setBool("notif_task", taskNotif);
    prefs.setBool("notif_reminder", reminderNotif);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Notification Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text("General Notifications"),
            value: generalNotif,
            onChanged: (v) {
              setState(() => generalNotif = v);
              savePrefs();
            },
          ),
          SwitchListTile(
            title: const Text("Task Updates"),
            value: taskNotif,
            onChanged: (v) {
              setState(() => taskNotif = v);
              savePrefs();
            },
          ),
          SwitchListTile(
            title: const Text("Daily Reminder"),
            value: reminderNotif,
            onChanged: (v) {
              setState(() => reminderNotif = v);
              savePrefs();
            },
          ),
        ],
      ),
    );
  }
}
