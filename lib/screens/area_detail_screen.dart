import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/jalali_utils.dart';
import '../models/loop.dart';
import '../models/loop_type.dart';
import '../providers/loop_provider.dart';
import 'text_capture_screen.dart';

class AreaDetailScreen extends StatefulWidget {
  final LifeArea area;
  const AreaDetailScreen({super.key, required this.area});

  @override
  State<AreaDetailScreen> createState() => _AreaDetailScreenState();
}

class _AreaDetailScreenState extends State<AreaDetailScreen> {
  List<Loop> _items = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await context.read<LoopProvider>().byCategory(widget.area.name);
    setState(() {
      _items = all;
      _loading = false;
    });
  }

  List<Loop> get _filtered {
    if (_query.isEmpty) return _items;
    return _items.where((l) => l.title.contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.area.label)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'جستجو...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('چیزی ثبت نشده است.', style: TextStyle(color: AppColors.textSecondary)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 24),
                        itemBuilder: (context, i) {
                          final l = _filtered[i];
                          return Row(
                            children: [
                              Icon(l.type.icon, color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                    if (l.dueDate != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          JalaliUtils.formatShort(l.dueDate!),
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const TextCaptureScreen()));
          _load();
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
