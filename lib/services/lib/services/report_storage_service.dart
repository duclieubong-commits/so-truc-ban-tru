import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:so_truc_ban_tru/models/duty_report_model.dart';

class ReportStorageService {
  static const String _keyReports = 'saved_duty_reports';

  // Lấy toàn bộ danh sách biên bản đã lưu (xếp theo thời gian mới nhất lên đầu)
  static Future<List<DutyReport>> getAllReports() async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList(_keyReports) ?? [];
    List<DutyReport> reports = [];
    for (var str in listJson) {
      try {
        reports.add(DutyReport.fromMap(jsonDecode(str)));
      } catch (e) {
        // Bỏ qua bản ghi lỗi nếu có
      }
    }
    reports.sort((a, b) => b.dutyDate.compareTo(a.dutyDate));
    return reports;
  }

  // Lưu mới hoặc cập nhật biên bản
  static Future<void> saveOrUpdateReport(DutyReport report) async {
    final prefs = await SharedPreferences.getInstance();
    List<DutyReport> reports = await getAllReports();

    int index = reports.indexWhere((r) => r.id == report.id);
    if (index >= 0) {
      reports[index] = report; // Cập nhật biên bản cũ
    } else {
      reports.insert(0, report); // Thêm biên bản mới
    }

    final listJson = reports.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_keyReports, listJson);
  }

  // Xóa một biên bản
  static Future<void> deleteReport(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<DutyReport> reports = await getAllReports();
    reports.removeWhere((r) => r.id == id);
    final listJson = reports.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_keyReports, listJson);
  }
}
