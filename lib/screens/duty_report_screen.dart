import 'package:flutter/material.dart';
import 'package:so_truc_ban_tru/models/duty_report_model.dart';
import 'package:so_truc_ban_tru/widgets/room_attendance_table_widget.dart';
import 'package:so_truc_ban_tru/services/report_pdf_service.dart';

class DutyReportScreen extends StatefulWidget {
  const DutyReportScreen({Key? key}) : super(key: key);

  @override
  State<DutyReportScreen> createState() => _DutyReportScreenState();
}

class _DutyReportScreenState extends State<DutyReportScreen> {
  late DutyReport report;

  // Quản lý nhập họ và tên 3 người trực
  late TextEditingController _teacher1Ctrl;
  late TextEditingController _teacher2Ctrl;
  late TextEditingController _teacher3Ctrl;

  // Người ký biên bản: mặc định là người số 1 (index = 0)
  int _signerIndex = 0;

  @override
  void initState() {
    super.initState();
    report = DutyReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dutyDate: DateTime.now(),
      teachers: ['', '', ''], // 3 vị trí người trực
    );

    _teacher1Ctrl = TextEditingController(text: report.teachers[0]);
    _teacher2Ctrl = TextEditingController(text: report.teachers[1]);
    _teacher3Ctrl = TextEditingController(text: report.teachers[2]);

    _syncSigner();
  }

  // Đồng bộ người ký tên vào biên bản
  void _syncSigner() {
    if (_signerIndex == 0) {
      report.representativeTeacher = _teacher1Ctrl.text.trim();
    } else if (_signerIndex == 1) {
      report.representativeTeacher = _teacher2Ctrl.text.trim();
    } else {
      report.representativeTeacher = _teacher3Ctrl.text.trim();
    }
  }

  @override
  void dispose() {
    _teacher1Ctrl.dispose();
    _teacher2Ctrl.dispose();
    _teacher3Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biên Bản Trực Bán Trú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Xuất văn bản PDF',
            onPressed: () async {
              _syncSigner();
              await ReportPdfService.generateAndSharePdf(report);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // KHỐI 1: THÔNG TIN TRƯỜNG & THỜI GIAN
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
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Text('Ngày trực: ${report.dutyDate.day}/${report.dutyDate.month}/${report.dutyDate.year}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // KHỐI 2: NHẬP HỌ TÊN 03 NGƯỜI TRỰC VÀ CHỌN NGƯỜI KÝ
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
                        Text(
                          'Thành viên ca trực (03 người)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '* Mặc định Người số 1 sẽ ký biên bản. Bạn có thể tích chọn người khác nếu có thay đổi.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),

                    // Người trực 1 (Mặc định ký)
                    TextField(
                      controller: _teacher1Ctrl,
                      decoration: InputDecoration(
                        labelText: '1. Họ và tên người trực 1 (Chính)',
                        prefixIcon: const Icon(Icons.person),
                        suffixIcon: _signerIndex == 0
                            ? const Chip(
                                label: Text('Ký biên bản', style: TextStyle(fontSize: 11, color: Colors.white)),
                                backgroundColor: Color(0xFF1E56A0),
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        report.teachers[0] = val.trim();
                        if (_signerIndex == 0) _syncSigner();
                      },
                    ),
                    const SizedBox(height: 10),

                    // Người trực 2
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
                        report.teachers[1] = val.trim();
                        if (_signerIndex == 1) _syncSigner();
                      },
                    ),
                    const SizedBox(height: 10),

                    // Người trực 3
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
                        report.teachers[2] = val.trim();
                        if (_signerIndex == 2) _syncSigner();
                      },
                    ),
                    const SizedBox(height: 12),

                    // Tùy chọn chuyển người ký biên bản
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Người đại diện ký biên bản:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<int>(
                                  title: const Text('Người 1', style: TextStyle(fontSize: 13)),
                                  value: 0,
                                  groupValue: _signerIndex,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) {
                                    setState(() {
                                      _signerIndex = val!;
                                      _syncSigner();
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  title: const Text('Người 2', style: TextStyle(fontSize: 13)),
                                  value: 1,
                                  groupValue: _signerIndex,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) {
                                    setState(() {
                                      _signerIndex = val!;
                                      _syncSigner();
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  title: const Text('Người 3', style: TextStyle(fontSize: 13)),
                                  value: 2,
                                  groupValue: _signerIndex,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) {
                                    setState(() {
                                      _signerIndex = val!;
                                      _syncSigner();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // MỤC 1: SĨ SỐ ĐẾN TRƯỜNG (LỚP 6A - 9B)
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
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: report.classAttendances.length,
                      itemBuilder: (ctx, i) {
                        final ca = report.classAttendances[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ca.className, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('${ca.present}/${ca.total}'),
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

            // MỤC 5.1 & 5.2: GIÁM SÁT ĂN TRƯA, TỐI
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

            // MỤC 6: QUẢN LÝ TỰ HỌC
            RoomAttendanceTableWidget(
              title: '6. Quản lý giờ tự học ở nội trú',
              timeFrame: '19h00 – 20h30',
              rooms: report.studyAttendances,
              onDataChanged: () => setState(() {}),
            ),

            // MỤC 7: SĨ SỐ & ĂN SÁNG HÔM SAU
            RoomAttendanceTableWidget(
              title: '7. Theo dõi sĩ số và HS ăn sáng hôm sau',
              timeFrame: '06h00 – 06h45',
              rooms: report.breakfastAttendances,
              onDataChanged: () => setState(() {}),
            ),

            // CÁC MỤC NHẬN XÉT (3, 4, 8, 9)
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
