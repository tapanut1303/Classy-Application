import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_button.dart';

/// นาฬิกาจับเวลาอ่านหนังสือแบบ Pomodoro (25 นาที)
class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const int _totalSeconds = 25 * 60; // 25 นาที

  int _secondsLeft = _totalSeconds;
  bool _isRunning = false;
  Timer? _timer; // ใส่ ? เพราะตอนยังไม่เริ่มจับเวลาจะเป็น null

  @override
  void dispose() {
    _timer?.cancel(); // สำคัญมาก ไม่งั้นนาฬิกาจะเดินต่อแม้ปิดหน้าไปแล้ว
    super.dispose();
  }

  /// เริ่ม / หยุดชั่วคราว
  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }

    setState(() => _isRunning = true);
    // สั่งให้ทำงานทุก ๆ 1 วินาที
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
          _isRunning = false;
        });
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  /// ตั้งเวลาใหม่กลับไปที่ 25 นาที
  void _reset() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _totalSeconds;
      _isRunning = false;
    });
  }

  /// แปลงวินาทีเป็นข้อความ mm:ss เช่น 1500 -> "25:00"
  String get _timeText {
    final minutes = _secondsLeft ~/ 60; // ~/ คือหารเอาแต่จำนวนเต็ม
    final seconds = _secondsLeft % 60; // % คือเอาเศษ
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // สัดส่วนเวลาที่เหลือ ใช้วาดวงแหวนความคืบหน้า
    final progress = _secondsLeft / _totalSeconds;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Focus Timer', style: AppText.serif(context, size: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Spacer(),

            // วงกลมจับเวลา
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2.5,
                      backgroundColor: Theme.of(context).dividerColor,
                      valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    ),
                  ),
                  Text(_timeText, style: AppText.serif(context, size: 52)),
                ],
              ),
            ),
            const SizedBox(height: 26),

            Text('กำลังอ่าน Database Systems', style: AppText.muted(context)),
            const Spacer(),

            ClassyButton(
              label: _isRunning ? 'หยุดพัก' : 'เริ่มโฟกัส',
              color: AppColors.ink,
              onPressed: _toggleTimer,
            ),
            const SizedBox(height: 10),
            ClassyButton(
              label: 'ตั้งเวลาใหม่',
              outlined: true,
              color: AppColors.gold,
              onPressed: _reset,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
