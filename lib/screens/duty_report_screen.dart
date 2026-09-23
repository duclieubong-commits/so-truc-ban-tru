import 'package:flutter/material.dart';
import 'package:so_truc_ban_tru/models/duty_report_model.dart';
import 'package:so_truc_ban_tru/widgets/room_attendance_table_widget.dart';
import 'package:so_truc_ban_tru/services/report_pdf_service.dart';
import 'package:so_truc_ban_tru/services/report_storage_service.dart';

class DutyReportScreen extends StatefulWidget {
  final DutyReport? existingReport; // Truyền biên bản cũ vào để sửa nếu có

  const DutyReportScreen({Key? key, this.existingReport}) : super(key: key);

  @override
  State<DutyReportScreen> createState() => _DutyReportScreenState();
}

class _DutyReportScreenState extends State<DutyReportScreen> {
  late DutyReport report;

  late TextEditingController _teacher1Ctrl;
  late TextEditingController _teacher2Ctrl;
  late TextEditingController _teacher3Ctrl;
  int _signerIndex = 0;

  late List<TextEditingController> _classPresentControllers;
  late List<TextEditingController> _classTotalControllers;

  @override
  void initState() {
    super.initState();
    // Nếu có biên bản truyền vào thì lấy dữ liệu cũ, ngược lại tạo mới
    if (widget.existingReport != null) {
      report = widget.existingReport!;
    } else {
      report = DutyReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dutyDate: DateTime.now(),
        hour: 7,
        minute: 30,
        teachers: ['', '', ''],
      );
    }

    _teacher1Ctrl = TextEditingController(text: report.teachers.isNotEmpty ? report.teachers[0] : '');
    _teacher2Ctrl = TextEditingController(text: report.teachers.length > 1 ? report.teachers[1] : '');
    _teacher3Ctrl = TextEditingController(text: report.teachers.length > 2 ? report.teachers[2] : '');

    // Xác định người ký hiện tại
    if (report.representativeTeacher == _teacher2Ctrl.text && _teacher2Ctrl.text.isNotEmpty) {
      _signerIndex = 1;
    } else if (report.representativeTeacher == _teacher3Ctrl.text && _teacher3Ctrl.text.isNotEmpty) {
      _signerIndex = 2;
    } else {
      _signerIndex = 0;
    }

    _classPresentControllers = report.classAttendances
        .map((c) => TextEditingController(text: c.present > 0 ? c.present.toString() : ''))
        .toList();
    _classTotalControllers = report.classAttendances
        .map((c) => TextEditingController(text: c.total > 0 ? c.total.toString() : ''))
        .toList();

    _syncSigner();
  }

  void _syncSigner() {
    report.teachers = [
      _teacher1Ctrl.text.trim(),
      _teacher2Ctrl.text.trim(),
      _teacher3Ctrl.text.trim(),
    ];
    if (_signerIndex == 0) {
      report.representativeTeacher = _teacher1Ctrl.text.trim();
    } else if (_signerIndex == 1) {
      report.representativeTeacher = _teacher2Ctrl.text.trim();
    } else {
      report.representativeTeacher = _teacher3Ctrl.text.trim();
    }
  }

  Future<void> _saveReport() async {
    _syncSigner();
    await ReportStorageService.saveOrUpdateReport(report);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu biên bản thành công!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _teacher1Ctrl.dispose();
    _teacher2Ctrl.dispose();
    _teacher3Ctrl.dispose();
    for (var c in _classPresentControllers) { c.dispose(); }
    for (var c in _classTotalControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingReport != null ? 'Sửa Biên Bản' : 'Biên Bản Trực'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Lưu biên bản',
            onPressed: _saveReport,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Xuất PDF',
            onPressed: () async {
              await _saveReport();
              await ReportPdfService.generateAndSharePdf(report);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E56A0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.save),
          label: const Text('LƯU BIÊN BẢN NÀY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onPressed: () async {
            await _saveReport();
            if (mounted) Navigator.pop(context, true);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // KHỐI 1: TỰ CHỌN NGÀY VÀ GIỜ
            Card(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TRƯỜNG PTDTBT THCS PHAN THANH',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E56A0))),
                    const Text('TỔ QUẢN LÝ HS BÁN TRÚ',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                    const Divider(height: 16),
                    const Text('Thời gian lập biên bản (Chạm vào để đổi ngày/giờ):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: report.dutyDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                                locale: const Locale('vi', 'VN'),
                              );
                              if (pickedDate != null) {
                                setState(() { report.dutyDate = pickedDate; });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueGrey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.blue.shade50.withOpacity(0.3),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: Color(0xFF1E56A0), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Ngày ${report.dutyDate.day}/${report.dutyDate.month}/${report.dutyDate.year}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: report.hour, minute: report.minute),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  report.hour = pickedTime.hour;
                                  report.minute = pickedTime.minute;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueGrey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.blue.shade50.withOpacity(0.3),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Color(0xFF1E56A0), size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${report.hour.toString().padLeft(2, '0')}:${report.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // KHỐI 2: NHẬP HỌ TÊN 03 NGƯỜI TRỰC
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.group, color: Color(0xFF1E56A0)),
                        SizedBox(width: 8),
                        Text('Thành viên ca trực (03 người)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _teacher1Ctrl,
                      decoration: InputDecoration(
                        labelText: '1. Họ và tên người trực 1 (Mặc định ký)',
                        prefixIcon: const Icon(Icons.person),
                        suffixIcon: _signerIndex == 0
                            ? const Chip(
                                label: Text('Ký biên bản', style: TextStyle(fontSize: 11, color: Colors.white)),
                                backgroundColor: Color(0xFF1E56A0),
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        if (_signerIndex == 0) _syncSigner();
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _teacher2Ctrl,
                      decoration: InputDecoration(
                        labelText: '2. Họ và tên người trực 2',
                        prefixIcon: const Icon(Icons.person_outline),
                        suffixIcon: _signerIndex == 1
                            ? const Chip(
                                label: Text('Ký biên bản', style: TextStyle(fontSize: 11, color: Colors.white)),
                                backgroundColor: Color(0xFF1E56A0),
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        if (_signerIndex == 1) _syncSigner();
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _teacher3Ctrl,
                      decoration: InputDecoration(
                        labelText: '3. Họ và tên người trực 3',
                        prefixIcon: const Icon(Icons.person_outline),
                        suffixIcon: _signerIndex == 2
                            ? const Chip(
                                label: Text('Ký biên bản', style: TextStyle(fontSize: 11, color: Colors.white)),
                                backgroundColor: Color(0xFF1E56A0),
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        if (_signerIndex == 2) _syncSigner();
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Người ký: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Expanded(
                          child: Row(
                            children: [
                              Radio<int>(
                                value: 0,
                                groupValue: _signerIndex,
                                onChanged: (v) => setState(() { _signerIndex = v!; _syncSigner(); }),
                              ),
                              const Text('Người 1'),
                              Radio<int>(
                                value: 1,
                                groupValue: _signerIndex,
                                onChanged: (v) => setState(() { _signerIndex = v!; _syncSigner(); }),
                              ),
                              const Text('Người 2'),
                              Radio<int>(
                                value: 2,
                                groupValue: _signerIndex,
                                onChanged: (v) => setState(() { _signerIndex = v!; _syncSigner(); }),
                              ),
                              const Text('Người 3'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // MỤC 1: SĨ SỐ LỚP 6A - 9B
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Sĩ số học sinh đến trường (7h30 - 8h30)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: report.classAttendances.length,
                      itemBuilder: (ctx, i) {
                        final ca = report.classAttendances[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueGrey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Lớp ${ca.className}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E56A0))),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _classPresentControllers[i],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                        hintText: 'Có mặt',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        ca.present = int.tryParse(val.trim()) ?? 0;
                                      },
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: Text('/', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _classTotalControllers[i],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                        hintText: 'Tổng',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        ca.total = int.tryParse(val.trim()) ?? 0;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // MỤC 2: SĨ SỐ BÁN TRÚ
            RoomAttendanceTableWidget(
              title: '2. Theo dõi sĩ số học sinh bán trú',
              timeFrame: '12h15 – 13h30',
              rooms: report.noonRoomAttendances,
              onDataChanged: () => setState(() {}),
            ),

            // MỤC 5.1 & 5.2
            RoomAttendanceTableWidget(
              title: '5.1 Giám sát ăn trưa',
              timeFrame: '11h55 – 12h05',
              rooms: report.lunchAttendances,
              onDataChanged: () => setState(() {}),
            ),
            RoomAttendanceTableWidget(
              title: '5.2 Giám sát ăn tối',
              timeFrame: '18h00 – 18h10',
              rooms: report.dinnerAttendances,
              onDataChanged: () => setState(() {}),
            ),

            // MỤC 6
            RoomAttendanceTableWidget(
              title: '6. Quản lý giờ tự học ở nội trú',
              timeFrame: '19h00 – 20h30',
              rooms: report.studyAttendances,
              onDataChanged: () => setState(() {}),
            ),

            // MỤC 7
            RoomAttendanceTableWidget(
              title: '7. Theo dõi sĩ số và HS ăn sáng hôm sau',
              timeFrame: '06h00 – 06h45',
              rooms: report.breakfastAttendances,
              onDataChanged: () => setState(() {}),
            ),

            // CÁC MỤC NHẬN XÉT
            Card(
              margin: const EdgeInsets.all(12),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: report.dormRulesNote,
                      decoration: const InputDecoration(labelText: '3. Thực hiện nội quy kí túc'),
                      onChanged: (v) => report.dormRulesNote = v,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: report.hygieneNote,
                      decoration: const InputDecoration(labelText: '4. Vệ sinh cá nhân - phòng ở - khu vực'),
                      onChanged: (v) => report.hygieneNote = v,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: report.securityNote,
                      decoration: const InputDecoration(labelText: '8. Tình hình an ninh'),
                      onChanged: (v) => report.securityNote = v,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: report.incidentsAndSolutions,
                      decoration: const InputDecoration(labelText: '9. Bất thường và phương án xử lý'),
                      maxLines: 2,
                      onChanged: (v) => report.incidentsAndSolutions = v,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
