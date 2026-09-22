import 'package:flutter/material.dart';
import 'duty_report_model.dart';
import 'room_attendance_table_widget.dart';
import 'report_pdf_service.dart';

class DutyReportScreen extends StatefulWidget {
  const DutyReportScreen({Key? key}) : super(key: key);

  @override
  State<DutyReportScreen> createState() => _DutyReportScreenState();
}

class _DutyReportScreenState extends State<DutyReportScreen> {
  late DutyReport report;

  @override
  void initState() {
    super.initState();
    report = DutyReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dutyDate: DateTime.now(),
      teachers: ['Nguyễn Văn A', 'Trần Thị B', 'Lò Văn C'],
    );
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
              await ReportPdfService.generateAndSharePdf(report);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Thông tin mở đầu: Thời gian & Nhóm trực
            Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TRƯỜNG PTDTBT THCS PHAN THANH',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('TỔ QUẢN LÝ HS BÁN TRÚ',
                        style: TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 8),
                    Text('Ngày trực: ${report.dutyDate.day}/${report.dutyDate.month}/${report.dutyDate.year}'),
                    Text('Thành viên nhóm: ${report.teachers.where((t) => t.isNotEmpty).join(", ")}'),
                  ],
                ),
              ),
            ),

            // Mục 1: Sĩ số đến trường (Lớp 6A - 9B)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Sĩ số học sinh đến trường (7h30 - 8h30)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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

            // Mục 2: Sĩ số bán trú
            RoomAttendanceTableWidget(
              title: '2. Theo dõi sĩ số học sinh bán trú',
              timeFrame: '12h15 – 13h30',
              rooms: report.noonRoomAttendances,
              onDataChanged: () => setState(() {}),
            ),

            // Mục 5.1 & 5.2: Giám sát giờ ăn
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

            // Mục 6: Quản lý tự học
            RoomAttendanceTableWidget(
              title: '6. Quản lý giờ tự học ở nội trú',
              timeFrame: '19h00 – 20h30',
              rooms: report.studyAttendances,
              onDataChanged: () => setState(() {}),
            ),

            // Mục 7: Sĩ số & Ăn sáng hôm sau
            RoomAttendanceTableWidget(
              title: '7. Theo dõi sĩ số và HS ăn sáng hôm sau',
              timeFrame: '06h00 – 06h45',
              rooms: report.breakfastAttendances,
              onDataChanged: () => setState(() {}),
            ),

            // Các mục nhận xét đánh giá (3, 4, 8, 9)
            Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: report.dormRulesNote,
                      decoration: const InputDecoration(labelText: '3. Thực hiện nội quy kí túc'),
                      onChanged: (v) => report.dormRulesNote = v,
                    ),
                    TextFormField(
                      initialValue: report.hygieneNote,
                      decoration: const InputDecoration(labelText: '4. Vệ sinh cá nhân - phòng ở - khu vực'),
                      onChanged: (v) => report.hygieneNote = v,
                    ),
                    TextFormField(
                      initialValue: report.securityNote,
                      decoration: const InputDecoration(labelText: '8. Tình hình an ninh'),
                      onChanged: (v) => report.securityNote = v,
                    ),
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
