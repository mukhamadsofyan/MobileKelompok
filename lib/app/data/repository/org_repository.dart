import '../models/activity.dart';
import '../models/member.dart';

class OrgRepository {
  final List<Activity> _activities = [
    Activity(
      id: 1,
      title: 'Rapat Mingguan',
      date: DateTime.parse('2025-10-25'),
      description: 'Diskusi agenda kegiatan mingguan dan evaluasi program.',
    ),
    Activity(
      id: 2,
      title: 'Kegiatan Sosial',
      date: DateTime.parse('2025-10-30'),
      description: 'Aksi sosial bersama anggota organisasi di lingkungan kampus.',
    ),
  ];

final List<Member> _members = [
  Member(id: 1, name: 'Sofyan', role: 'Ketua'),
  Member(id: 2, name: 'Dina', role: 'Sekretaris'),
  Member(id: 3, name: 'Rizky', role: 'Anggota'),
];


  List<Activity> getActivities() => _activities;
  List<Member> getMembers() => _members;

  void saveAttendance(int activityId, String memberId, bool hadir) {
    print('Absensi: activity=$activityId, member=$memberId, hadir=$hadir');
  }
}
