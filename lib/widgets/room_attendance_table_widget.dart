import 'package:flutter/material.dart';
import 'duty_report_model.dart';

class RoomAttendanceTableWidget extends StatelessWidget {
  final String title;
  final String timeFrame;
  final List<RoomAttendance> rooms;
  final VoidCallback onDataChanged;

  const RoomAttendanceTableWidget({
    Key? key,
    required this.title,
    required this.timeFrame,
    required this.rooms,
    required this.onDataChanged,
  }) : super(key: key);

  void _editRoom(BuildContext context, RoomAttendance room) {
    final presentCtrl = TextEditingController(text: room.present.toString());
    final totalCtrl = TextEditingController(text: room.total.toString());
    final absentCtrl = TextEditingController(text: room.absentDetails);
    final noteCtrl = TextEditingController(text: room.note);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cập nhật Phòng ${room.roomNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: presentCtrl,
                      decoration: const InputDecoration(labelText: 'Có mặt'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: totalCtrl,
                      decoration: const InputDecoration(labelText: 'Tổng sĩ số'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: absentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên HS vắng (lí do)',
                  hintText: 'VD: Lò Văn A (về phép)',
                ),
              ),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              room.present = int.tryParse(presentCtrl.text) ?? room.present;
              room.total = int.tryParse(totalCtrl.text) ?? room.total;
              room.absentDetails = absentCtrl.text.trim();
              room.note = noteCtrl.text.trim();
              onDataChanged();
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Khung giờ: $timeFrame',
              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            const Divider(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final r = rooms[index];
                final isAbsent = r.absentDetails.isNotEmpty || (r.total > 0 && r.present < r.total);
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: isAbsent ? Colors.orange[100] : Colors.blue[50],
                    child: Text(
                      '${r.roomNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAbsent ? Colors.deepOrange : Colors.blue[800],
                      ),
                    ),
                  ),
                  title: Text(
                    'Có mặt: ${r.present}/${r.total}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isAbsent ? Colors.deepOrange : Colors.black87,
                    ),
                  ),
                  subtitle: isAbsent
                      ? Text('Vắng: ${r.absentDetails} ${r.note.isNotEmpty ? "(${r.note})" : ""}')
                      : const Text('Đầy đủ', style: TextStyle(color: Colors.green)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editRoom(context, r),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
