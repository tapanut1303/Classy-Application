import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/status_views.dart';
import '../../data/models/task_item.dart';
import '../../data/repositories/task_repository.dart';
import 'add_task_sheet.dart';
import 'widgets/task_tile.dart';

/// หน้ารายการงานที่ต้องส่ง
///
/// หน้านี้คือตัวอย่าง CRUD ครบวงจรที่สุดในแอป
///   Create -> ปุ่ม Add Task
///   Read   -> _load() อ่านจากตาราง tasks
///   Update -> ติ๊กช่องสี่เหลี่ยม (เปลี่ยนสถานะ) หรือแตะการ์ดเพื่อแก้ไข
///   Delete -> ปัดการ์ดไปทางซ้าย
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repo = TaskRepository();

  List<TaskItem> _tasks = [];
  bool _loading = true;
  String _filter = 'All'; // All / Today / Overdue / Done

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// READ — อ่านงานทั้งหมดจากฐานข้อมูล
  Future<void> _load() async {
    setState(() => _loading = true);

    final tasks = await _repo.getAll();
    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  /// CREATE — เปิดฟอร์มเพิ่มงานใหม่
  Future<void> _addTask() async {
    final saved = await showAddTaskSheet(context);
    if (saved == true) _load();
  }

  /// UPDATE — เปิดฟอร์มเดิมพร้อมข้อมูลงานที่จะแก้
  Future<void> _editTask(TaskItem task) async {
    final saved = await showAddTaskSheet(context, existing: task);
    if (saved == true) _load();
  }

  /// UPDATE — สลับสถานะเสร็จ / ยังไม่เสร็จ
  Future<void> _toggleDone(TaskItem task) async {
    await _repo.toggleDone(task);
    _load();
  }

  /// DELETE — ลบงาน พร้อมปุ่มเลิกทำใน SnackBar
  Future<void> _deleteTask(TaskItem task) async {
    await _repo.delete(task.id!);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ลบงานแล้ว'),
        action: SnackBarAction(
          label: 'เลิกทำ',
          onPressed: () async {
            await _repo.insert(task);
            _load();
          },
        ),
      ),
    );

    _load();
  }

  /// คัดงานตามตัวกรองที่เลือก
  List<TaskItem> get _visibleTasks {
    switch (_filter) {
      case 'Today':
        return _tasks.where((task) => task.isToday && !task.done).toList();
      case 'Overdue':
        return _tasks.where((task) => task.isOverdue).toList();
      case 'Done':
        return _tasks.where((task) => task.done).toList();
      default:
        return _tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _tasks.where((task) => !task.done).length;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveLayout(
          bottomPadding: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('เหลืออีก $remaining งาน', style: AppText.label(context)),
              const SizedBox(height: 6),
              Text('Pending Works', style: AppText.serif(context, size: 30)),
              const SizedBox(height: 18),

              _buildFilters(),
              const SizedBox(height: 16),

              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.ink,
        onPressed: _addTask,
        icon: const Icon(Icons.add, size: 18, color: Colors.white),
        label: Text('Add Task', style: AppText.sans(context, size: 13, color: Colors.white)),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const LoadingView();

    final tasks = _visibleTasks;

    if (tasks.isEmpty) {
      return const EmptyView(
        icon: Icons.auto_awesome_outlined,
        title: 'All caught up',
        message: 'ไม่มีงานค้างในหมวดนี้',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return TaskTile(
          task: task,
          onToggle: () => _toggleDone(task),
          onEdit: () => _editTask(task),
          onDelete: () => _deleteTask(task),
        );
      },
    );
  }

  /// แถวปุ่มตัวกรอง เลื่อนแนวนอนได้เผื่อจอแคบมาก
  Widget _buildFilters() {
    const filters = ['All', 'Today', 'Overdue', 'Done'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            GestureDetector(
              onTap: () => setState(() => _filter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: _filter == filter ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  filter,
                  style: AppText.sans(
                    context,
                    size: 12,
                    color: _filter == filter
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
