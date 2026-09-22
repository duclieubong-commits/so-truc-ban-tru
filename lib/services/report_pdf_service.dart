import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'duty_report_model.dart';

class ReportPdfService {
  static Future<void> generateAndSharePdf(DutyReport r) async {
    final pdf = pw.Document();

    // Bảng phụ trợ cho danh sách 9 phòng
    pw.Widget buildRoomTable(String title, String timeFrame, List<RoomAttendance> rooms) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$title ($timeFrame)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 3),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(40),
              1: const pw.FixedColumnWidth(90),
              2: const pw.FlexColumnWidth(),
              3: const pw.FixedColumnWidth(80),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Center(child: pw.Text('Phòng', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  pw.Center(child: pw.Text('Số HS có mặt/HS phòng', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8), textAlign: pw.TextAlign.center)),
                  pw.Center(child: pw.Text('Tên HS vắng (lí do)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  pw.Center(child: pw.Text('Ghi chú', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                ],
              ),
              ...rooms.map((room) => pw.TableRow(
                children: [
                  pw.Center(child: pw.Text('${room.roomNumber}', style: const pw.TextStyle(fontSize: 8))),
                  pw.Center(child: pw.Text('${room.present}/${room.total}', style: const pw.TextStyle(fontSize: 8))),
                  pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 4), child: pw.Text(room.absentDetails, style: const pw.TextStyle(fontSize: 8))),
                  pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 4), child: pw.Text(room.note, style: const pw.TextStyle(fontSize: 8))),
                ],
              )),
            ],
          ),
          pw.SizedBox(height: 8),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Tiêu ngữ & Quốc hiệu
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                children: [
                  pw.Text('TRƯỜNG PTDTBT THCS PHAN THANH', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('TỔ QUẢN LÝ HS BÁN TRÚ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Container(width: 80, height: 0.5, color: PdfColors.black),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text('CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Độc lập – Tự do – Hạnh phúc', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                  pw.Container(width: 100, height: 0.5, color: PdfColors.black),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // Tựa đề
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('BIÊN BẢN', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.Text('Về việc trực bán trú năm học 2026 – 2027', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 8),

          // Thời gian & Người trực
          pw.Text('Vào hồi: ${r.hour} giờ ${r.minute} phút ngày ${r.dutyDate.day} tháng ${r.dutyDate.month} năm ${r.dutyDate.year}, tại trường PTDTBT THCS Phan Thanh (trường chính).', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Chúng tôi gồm: 1, ${r.teachers[0]}    2, ${r.teachers[1]}    3, ${r.teachers[2]}', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Thực hiện các nội dung công việc như sau:', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
          pw.SizedBox(height: 6),

          // 1. Sĩ số trường
          pw.Text('1. Theo dõi sĩ số học sinh đến trường: (Điểm danh từ 7h30’ -8h30’)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(
            'Lớp 6A: TS ${r.classAttendances[0].present}/${r.classAttendances[0].total}   |   '
            'Lớp 7A: TS ${r.classAttendances[2].present}/${r.classAttendances[2].total}   |   '
            'Lớp 8A: TS ${r.classAttendances[4].present}/${r.classAttendances[4].total}   |   '
            'Lớp 9A: TS ${r.classAttendances[6].present}/${r.classAttendances[6].total}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            'Lớp 6B: TS ${r.classAttendances[1].present}/${r.classAttendances[1].total}   |   '
            'Lớp 7B: TS ${r.classAttendances[3].present}/${r.classAttendances[3].total}   |   '
            'Lớp 8B: TS ${r.classAttendances[5].present}/${r.classAttendances[5].total}   |   '
            'Lớp 9B: TS ${r.classAttendances[7].present}/${r.classAttendances[7].total}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 6),

          // 2. Sĩ số bán trú
          buildRoomTable('2. Theo dõi sĩ số học sinh bán trú', 'Điểm danh từ 12h15’ – 13h30’', r.noonRoomAttendances),

          // 3 & 4. Nội quy & Vệ sinh
          pw.Text('3. Theo dõi HS Thực hiện nội quy kí túc, tham gia các hoạt động:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text(r.dormRulesNote, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 4),

          pw.Text('4. Theo dõi HS vệ sinh cá nhân - phòng ở ; vệ sinh khu vực:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text(r.hygieneNote, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 6),

          // 5. Ăn trưa, tối
          buildRoomTable('5.1. Giám sát học sinh ăn trưa', 'Điểm danh từ 11h55’ – 12h05’', r.lunchAttendances),
          buildRoomTable('5.2. Giám sát học sinh ăn tối', 'Điểm danh từ 18h00’ – 18h10’', r.dinnerAttendances),

          // 6. Quản lý giờ tự học
          buildRoomTable('6. Quản lý giờ tự học của HS ở nội trú', 'từ 19h00’ – 20h30’', r.studyAttendances),

          // 7. Ăn sáng hôm sau
          buildRoomTable('7. Theo dõi sĩ số học sinh và HS ăn sáng hôm sau', 'Kiểm tra từ 06h00’ – 06h45’', r.breakfastAttendances),

          // 8 & 9. An ninh & Bất thường
          pw.Text('8. Tình hình an ninh:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text(r.securityNote, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 4),

          pw.Text('9. Những nội dung chi tiết bất thường diễn ra trong ngày, phương án xử lý:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text(r.incidentsAndSolutions, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 12),

          // Chữ ký
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                children: [
                  pw.Text('Phan Thanh, ngày ${r.dutyDate.day} tháng ${r.dutyDate.month} năm ${r.dutyDate.year}', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                  pw.Text('Đại diện nhóm trực', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('(ký và ghi rõ họ tên)', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                  pw.SizedBox(height: 35),
                  pw.Text(r.representativeTeacher.isNotEmpty ? r.representativeTeacher : r.teachers[0], style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // Mở hộp thoại in hoặc chia sẻ trực tiếp qua Zalo / Mail
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
