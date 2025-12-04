import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';


class CrewHomePage extends StatelessWidget {
  const CrewHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xffF6F6F8),
        elevation: 0,
        title: const Text(
          "Crew",
          style: TextStyle(fontFamily: "Poppins", fontSize: 32, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, size: 30),
                Positioned(
                  right: 3,
                  top: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Quick stats",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _quickStatCard("12", "Task completed", LucideIcons.checkCircle, Color(0x202B6CEE),Color(0xFF2B6CEE))),
              const SizedBox(width: 12),
              Expanded(child: _quickStatCard("3", "Joined Crew", LucideIcons.rocket, Color(0x209013FE),Color(0xFF9013FE))),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            "Your crews",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Make these crew cards tappable by providing an onTap callback
          _crewCard(
            context: context,
            title: "English speaking",
            iconColor: Colors.blue,
            progress: 75/100,
            subtitle: "This week we are focusing on improving…",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrewDetailPage(title: "English speaking", progress: 0.70),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          _crewCard(
            context: context,
            title: "Python Course",
            iconColor: Colors.teal,
            progress: 0.40,
            subtitle: "Hey everyone, solve the given problem…",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrewDetailPage(title: "Python Course", progress: 0.40),
                ),
              );
            },
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Crews"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Create"),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: "Join"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Quick Stat Card Widget
  Widget _quickStatCard(String value, String label, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(backgroundColor: bgColor, child: Icon(icon, color: iconColor)),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ]),
    );
  }

  // Tappable Crew Card Widget (accepts onTap)
  Widget _crewCard({
    required BuildContext context,
    required String title,
    required Color iconColor,
    required double progress,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Progress", style: TextStyle(fontSize:16, color: Colors.grey)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              color: Colors.purpleAccent,
              backgroundColor: Colors.grey.shade300,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Text("Captain : $subtitle", style: const TextStyle(fontSize: 13, color: Color.fromARGB(214, 0, 0, 0))),
        ]),
      ),
    );
  }
}

// Simple Crew Detail Page to demonstrate navigation + receive data
class CrewDetailPage extends StatelessWidget {
  final String title;
  final double progress;

  const CrewDetailPage({Key? key, required this.title, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xfff2f2f7),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft, child: Text("Progress", style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, color: Colors.purpleAccent, backgroundColor: Colors.grey.shade300, minHeight: 10),
          const SizedBox(height: 20),
          const Text(
            "This is a simple details page. Replace with real content: members list, feed, tasks, chat etc.",
            style: TextStyle(color: Colors.black54),
          ),
        ]),
      ),
    );
  }
}
