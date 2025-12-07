// lib/services/progress_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1) Crew overall progress (percentage 0.0 - 1.0)
  // Approach: if crew has N tasks total and M total completions (unique task completions by any user),
  // crewProgress = average of members' completion ratio OR simply tasksCompletedCount / (N * membersCount)
  // Simpler: compute average of member completion ratio (safer if tasks are per-user).
  Future<double> getCrewOverallProgress(String crewId) async {
    final crewSnap = await _db.collection('crews').doc(crewId).get();
    if (!crewSnap.exists) return 0.0;
    final crew = crewSnap.data()!;
    final List members = List.from(crew['members'] ?? []);
    final tasksSnap = await _db.collection('crews').doc(crewId).collection('tasks').get();
    final tasks = tasksSnap.docs;

    if (tasks.isEmpty || members.isEmpty) return 0.0;

    double totalRatioSum = 0.0;
    for (final memberId in members) {
      int completed = 0;
      for (final t in tasks) {
        final completedBy = List.from(t.data()['completedBy'] ?? []);
        if (completedBy.contains(memberId)) completed++;
      }
      totalRatioSum += (tasks.length == 0) ? 0.0 : (completed / tasks.length);
    }

    return totalRatioSum / members.length; // between 0 and 1
  }

  // 2) User progress in a crew — fraction of tasks completed by the user in that crew.
  Future<double> getUserProgressInCrew(String crewId, String userId) async {
    final tasksSnap = await _db.collection('crews').doc(crewId).collection('tasks').get();
    final tasks = tasksSnap.docs;
    if (tasks.isEmpty) return 0.0;
    int completed = 0;
    for (final t in tasks) {
      final completedBy = List.from(t.data()['completedBy'] ?? []);
      if (completedBy.contains(userId)) completed++;
    }
    return completed / tasks.length;
  }

  // 3) Toggle task completion for current user — updates task.completedBy and user counters + streak.
  Future<void> toggleTaskCompletion({
    required String crewId,
    required String taskId,
    required String userId,
  }) async {
    final taskRef = _db.collection('crews').doc(crewId).collection('tasks').doc(taskId);
    final userRef = _db.collection('users').doc(userId);

    final taskSnap = await taskRef.get();
    if (!taskSnap.exists) return;

    final List completedBy = List.from(taskSnap.data()?['completedBy'] ?? []);
    final bool already = completedBy.contains(userId);

    final batch = _db.batch();

    if (already) {
      // remove completion
      batch.update(taskRef, {
        'completedBy': FieldValue.arrayRemove([userId])
      });
      // decrement user's tasksCompleted
      batch.set(userRef, {
        'tasksCompleted': FieldValue.increment(-1),
      }, SetOptions(merge: true));
    } else {
      // add completion
      batch.update(taskRef, {
        'completedBy': FieldValue.arrayUnion([userId])
      });
      // increment user's tasksCompleted
      batch.set(userRef, {
        'tasksCompleted': FieldValue.increment(1),
      }, SetOptions(merge: true));
      // update streak (only when marking completed)
      await _updateUserStreakOnComplete(userRef);
    }

    await batch.commit();
  }

 Future<void> _updateUserStreakOnComplete(DocumentReference userRef) async {
  final snap = await userRef.get();
  final data = snap.data() as Map<String, dynamic>? ?? {};

  final lastTs = data["lastActiveAt"] as Timestamp?;
  final previousStreak = (data["streak"] ?? 0) as int;

  final now = DateTime.now().toUtc();
  final today = DateTime.utc(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  int newStreak = 1;

  if (lastTs != null) {
    final lastDate = lastTs.toDate().toUtc();
    final lastDay = DateTime.utc(lastDate.year, lastDate.month, lastDate.day);

    if (lastDay == today) {
      // Already completed a task today → keep streak same
      newStreak = previousStreak;
    } 
    else if (lastDay == yesterday) {
      // Completed yesterday → increment streak
      newStreak = previousStreak + 1;
    } 
    else {
      // Broke the streak → restart
      newStreak = 1;
    }
  }

  await userRef.set({
    "streak": newStreak,
    "lastActiveAt": Timestamp.fromDate(now),
  }, SetOptions(merge: true));
}

  // 5) Quick helper: compute user stats (tasksCompleted, crewsJoined, streak)
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final snap = await _db.collection('users').doc(userId).get();
    if (!snap.exists) return {
      'tasksCompleted': 0,
      'crewsJoined': 0,
      'streak': 0,
    };
    final data = snap.data()!;
    return {
      'tasksCompleted': data['tasksCompleted'] ?? 0,
      'crewsJoined': data['crewsJoined'] ?? 0,
      'streak': data['streak'] ?? 0,
    };
  }

  
  Future<int> getTotalTasksCompleted(String uid) async {
  int count = 0;

  final userDoc = await _db.collection("users").doc(uid).get();
  final userData = userDoc.data() ?? {};
  final crewIds = List<String>.from(userData["crews"] ?? []);

  for (String crewId in crewIds) {
    final tasksSnap = await _db
        .collection("crews")
        .doc(crewId)
        .collection("tasks")
        .get();

    for (var task in tasksSnap.docs) {
      final data = task.data();
      final completedBy = List<String>.from(data["completedBy"] ?? []);

      if (completedBy.contains(uid)) {
        count++;
      }
    }
  }

  return count;
}


  Future<int> getCrewsJoined(String uid) async {
    final userDoc = await _db.collection("users").doc(uid).get();
    final data = userDoc.data() ?? {};
    return List<String>.from(data["crews"] ?? []).length;
  }
}
