import 'package:flutter/material.dart';
import 'package:so_truc_ban_tru/models/duty_report_model.dart';
import 'package:so_truc_ban_tru/screens/duty_report_screen.dart';
import 'package:so_truc_ban_tru/services/report_storage_service.dart';
import 'package:so_truc_ban_tru/services/report_pdf_service.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  List<DutyReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final list = await ReportStorageService.getAllReports();
    setState(() {
      _reports = list;
      _isLoading = false;
    });
  }

  Future<void> _openReportEditor([DutyReport? report]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DutyReportScreen(existingReport: report),
      ),
    );
    if (result == true) {
      _loadReports();
    }
  }

  Future<void> _confirmDelete(DutyReport report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa biên bản ngày ${report.dutyDate.day}/${report.dutyDate.month}/${report.dutyDate.year}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ReportStorageService.deleteReport(report.id);
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ Trực Bán Trú'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E56A0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tạo ca trực mới'),
        onPressed: () => _openReportEditor(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 70, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text(
                        'Chưa có biên bản nào được lưu',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Bấm "Tạo ca trực mới" ở góc dưới để bắt đầu',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    itemCount: _reports.length,
                    itemBuilder: (ctx, i) {
                      final r = _reports[i];
                      final teachersStr = r.teachers.where((t) => t.isNotEmpty).join(", ");
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _openReportEditor(r), // Chạm để sửa
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month, color: Color(0xFF1E56A0), size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Ngày ${r.dutyDate.day}/${r.dutyDate.month}/${r.dutyDate.year}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Text(
                                  'Người trực: ${teachersStr.isNotEmpty ? teachersStr : "Chưa nhập tên"}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                if (r.representativeTeacher.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Người ký: ${r.representativeTeacher}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 18),
                                      label: const Text('Xuất PDF', style: TextStyle(color: Colors.red)),
                                      onPressed: () => ReportPdfService.generateAndSharePdf(r),
                                    ),
                                    const SizedBox(width: 4),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                                      label: const Text('Xóa', style: TextStyle(color: Colors.grey)),
                                      onPressed: () => _confirmDelete(r),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
