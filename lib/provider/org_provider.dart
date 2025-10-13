import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/activity.dart';
import '../models/member.dart';

class OrgProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();

  List<Activity> _activities = [];
  List<Member> _members = [];

  List<Activity> get activities => _activities;
  List<Member> get members => _members;

  bool loading = false;

  Future<void> loadAll() async {
    loading = true;
    notifyListeners();
    _activities = await _db.getActivities();
    _members = await _db.getMembers();
    loading = false;
    notifyListeners();
  }

  Future<void> addActivity(Activity a) async {
    await _db.insertActivity(a);
    await loadAll();
  }

  Future<void> updateActivity(Activity a) async {
    await _db.updateActivity(a);
    await loadAll();
  }

  Future<void> removeActivity(int id) async {
    await _db.deleteActivity(id);
    await loadAll();
  }

  Future<void> addMember(Member m) async {
    await _db.insertMember(m);
    await loadAll();
  }

  Future<void> updateMember(Member m) async {
    await _db.updateMember(m);
    await loadAll();
  }

  Future<void> removeMember(int id) async {
    await _db.deleteMember(id);
    await loadAll();
  }

  Future<void> markAttendance(int activityId, int memberId, bool present) async {
    await _db.markAttendance(activityId, memberId, present);
    // no need to reload everything, but for simplicity:
    await loadAll();
  }
}
