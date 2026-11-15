import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/classy_card.dart';
import '../../data/models/team_member.dart';
import '../../data/profile_data.dart';

/// หน้าแสดงข้อมูลสมาชิกในกลุ่ม (ข้อกำหนดของอาจารย์)
///
/// responsive: จอกว้างจะวางการ์ดสมาชิกเรียงข้างกัน จอแคบเรียงลงมา
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ATELIER', style: AppText.label(context)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ResponsiveLayout(
            topPadding: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The people behind Classy',
                    style: AppText.serif(context, size: 30, height: 1.25)),
                const SizedBox(height: 10),
                Text(
                  'ผู้จัดทำแอปสำหรับวางแผนการเรียน ของโปรเจกต์วิชา Application Development Mobile\n'
                  'รหัสวิชา 02739342',
                  style: AppText.muted(context),
                ),
                const SizedBox(height: 26),

                ResponsiveGrid(
                  children: [
                    for (final member in ProfileData.team)
                      _MemberCard(member: member),
                  ],
                ),

                const SizedBox(height: 22),
                Center(
                  child: Text('BUILT WITH FLUTTER · SQLITE · OPEN-METEO API',
                      style: AppText.label(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final TeamMember member;

  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return ClassyCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.18),
              border: Border.all(color: AppColors.gold),
            ),
            child: Text(member.initials, style: AppText.serif(context, size: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.role.toUpperCase(), style: AppText.label(context)),
                const SizedBox(height: 5),
                Text(member.name, style: AppText.serif(context, size: 18)),
                const SizedBox(height: 3),
                Text('${member.studentId}  ·  ${member.faculty}',
                    style: AppText.muted(context, size: 11)),
                const SizedBox(height: 8),
                Text(member.bio, style: AppText.muted(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
