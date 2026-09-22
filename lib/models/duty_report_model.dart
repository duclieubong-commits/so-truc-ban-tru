import 'dart:convert';

/// Dữ liệu điểm danh theo từng phòng (áp dụng cho các mục 2, 5.1, 5.2, 6, 7)
class RoomAttendance {
  final int roomNumber; // Phòng 1 -> 9
  int present; // Số HS có mặt
  int total; // Tổng số HS phòng
  String absentDetails; // Tên HS vắng (kèm lí do)
  String note; // Ghi chú

  RoomAttendance({
    required this.roomNumber,
    this.present = 0,
    this.total = 0,
    this.absentDetails = '',
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
    'roomNumber': roomNumber,
    'present': present,
    'total': total,
    'absentDetails': absentDetails,
    'note': note,
  };

  factory RoomAttendance.fromMap(Map<String, dynamic> map) => RoomAttendance(
    roomNumber: map['roomNumber'] ?? 0,
    present: map['present'] ?? 0,
    total: map['total'] ?? 0,
    absentDetails: map['absentDetails'] ?? '',
    note: map['note'] ?? '',
  );
}

/// Dữ liệu sĩ số theo lớp (Mục 1: 6A đến 9B)
class ClassAttendance {
  final String className; // 6A, 6B, 7A, 7B, 8A, 8B, 9A, 9B
  int present;
  int total;

  ClassAttendance({
    required this.className,
    this.present = 0,
    this.total = 0,
  });

  Map<String, dynamic> toMap() => {
    'className': className,
    'present': present,
    'total': total,
  };
}

/// Toàn bộ biên bản trực bán trú
class DutyReport {
  String id;
  DateTime dutyDate;
  int hour;
  int minute;
  List<String> teachers; // Tối đa 3 giáo viên trực
  
  // 1. Sĩ số học sinh đến trường (7h30 - 8h30)
  List<ClassAttendance> classAttendances;

  // 2. Sĩ số bán trú trưa (12h15 - 13h30)
  List<RoomAttendance> noonRoomAttendances;

  // 3 & 4. Nội quy & Vệ sinh
  String dormRulesNote;
  String hygieneNote;

  // 5. Giám sát ăn trưa & tối
  List<RoomAttendance> lunchAttendances; // 11h55 - 12h05
  List<RoomAttendance> dinnerAttendances; // 18h00 - 18h10

  // 6. Quản lý tự học (19h00 - 20h30)
  List<RoomAttendance> studyAttendances;

  // 7. Sĩ số & Ăn sáng hôm sau (06h00 - 06h45)
  List<RoomAttendance> breakfastAttendances;

  // 8 & 9. An ninh & Sự việc bất thường
  String securityNote;
  String incidentsAndSolutions;

  String representativeTeacher; // Đại diện ký tên

  DutyReport({
    required this.id,
    required this.dutyDate,
    this.hour = 7,
    this.minute = 30,
    List<String>? teachers,
    List<ClassAttendance>? classAttendances,
    List<RoomAttendance>? noonRoomAttendances,
    this.dormRulesNote = 'Học sinh chấp hành tốt nội quy kí túc xá.',
    this.hygieneNote = 'Phòng ở và khu vực chung sạch sẽ, ngăn nắp.',
    List<RoomAttendance>? lunchAttendances,
    List<RoomAttendance>? dinnerAttendances,
    List<RoomAttendance>? studyAttendances,
    List<RoomAttendance>? breakfastAttendances,
    this.securityNote = 'Khu vực nội trú an toàn, ổn định, không có vụ việc bất thường.',
    this.incidentsAndSolutions = 'Không có.',
    this.representativeTeacher = '',
  })  : teachers = teachers ?? ['', '', ''],
        classAttendances = classAttendances ?? [
          ClassAttendance(className: '6A'), ClassAttendance(className: '6B'),
          ClassAttendance(className: '7A'), ClassAttendance(className: '7B'),
          ClassAttendance(className: '8A'), ClassAttendance(className: '8B'),
          ClassAttendance(className: '9A'), ClassAttendance(className: '9B'),
        ],
        noonRoomAttendances = noonRoomAttendances ?? _generateDefaultRooms(),
        lunchAttendances = lunchAttendances ?? _generateDefaultRooms(),
        dinnerAttendances = dinnerAttendances ?? _generateDefaultRooms(),
        studyAttendances = studyAttendances ?? _generateDefaultRooms(),
        breakfastAttendances = breakfastAttendances ?? _generateDefaultRooms();

  static List<RoomAttendance> _generateDefaultRooms() {
    return List.generate(9, (index) => RoomAttendance(roomNumber: index + 1));
  }
}
