import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  String? _fileName;
  bool _isProcessing = false;
  bool _isDone = false;
  Map<String, dynamic>? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập câu hỏi từ Excel'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.coolGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Hướng dẫn định dạng file',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SheetGuide(
                    sheet: 'Sheet 1: MULTIPLE_CHOICE',
                    columns: 'Question | A | B | C | D | Answer',
                    example: 'Thủ đô VN? | HCM | Huế | Hà Nội | Đà Nẵng | C',
                  ),
                  const SizedBox(height: 8),
                  _SheetGuide(
                    sheet: 'Sheet 2: TRUE_FALSE',
                    columns: 'Question | Answer',
                    example: 'Trái đất hình cầu? | TRUE',
                  ),
                  const SizedBox(height: 8),
                  _SheetGuide(
                    sheet: 'Sheet 3: NUMERIC',
                    columns: 'Question | Answer',
                    example: '1/2 + 1/2 = ? | 1',
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 24),

            // Upload area
            if (!_isProcessing && !_isDone)
              _buildUploadArea(context),

            if (_isProcessing)
              _buildProcessingState(),

            if (_isDone && _result != null)
              _buildResultState(_result!),

            const SizedBox(height: 24),

            // Download template button
            OutlinedButton.icon(
              onPressed: _downloadTemplate,
              icon: const Icon(Icons.download),
              label: const Text('Tải file mẫu Excel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppTheme.primaryColor),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 200,
        decoration: BoxDecoration(
          color: _fileName != null
              ? AppTheme.primaryColor.withOpacity(0.08)
              : const Color(0xFFF5F5FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _fileName != null ? AppTheme.primaryColor : const Color(0xFFE0E0FF),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_fileName == null) ...[
              Icon(Icons.upload_file, size: 56, color: AppTheme.primaryColor.withOpacity(0.6)),
              const SizedBox(height: 12),
              const Text(
                'Kéo thả hoặc click để chọn file',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hỗ trợ: .xlsx, .xls (tối đa 10MB)',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ] else ...[
              const Icon(Icons.description, size: 48, color: AppTheme.primaryColor),
              const SizedBox(height: 12),
              Text(
                _fileName!,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => setState(() => _fileName = null),
                child: const Text('Chọn file khác'),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildProcessingState() {
    return Column(
      children: [
        Container(
          height: 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
              ),
              const SizedBox(height: 20),
              const Text(
                'Đang xử lý file...',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI đang phân loại câu hỏi',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildResultState(Map<String, dynamic> result) {
    final hasErrors = (result['errorRows'] as int) > 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
          ),
          child: Column(
            children: [
              Icon(
                hasErrors ? Icons.warning_amber : Icons.check_circle,
                size: 64,
                color: hasErrors ? AppTheme.warningColor : AppTheme.accentColor,
              ).animate().scale(duration: 500.ms),
              const SizedBox(height: 16),
              Text(
                hasErrors ? 'Import hoàn thành (có lỗi)' : 'Import thành công!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ResultStat(
                    label: 'Tổng dòng',
                    value: '${result['totalRows']}',
                    color: AppTheme.primaryColor,
                  ),
                  _ResultStat(
                    label: 'Thành công',
                    value: '${result['successRows']}',
                    color: AppTheme.accentColor,
                  ),
                  _ResultStat(
                    label: 'Lỗi',
                    value: '${result['errorRows']}',
                    color: result['errorRows'] > 0 ? AppTheme.errorColor : Colors.grey,
                  ),
                ],
              ),
              if (hasErrors && result['errors'] != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Chi tiết lỗi:', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...(result['errors'] as List).take(5).map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Sheet ${e['sheet']}, Dòng ${e['row']}: ${e['error']}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.errorColor),
                  ),
                )),
              ],
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _isDone = false;
                  _fileName = null;
                  _result = null;
                }),
                child: const Text('Import thêm'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Xong'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result != null) {
      setState(() => _fileName = result.files.single.name);
    }
  }

  Future<void> _processFile() async {
    if (_fileName == null) return;
    setState(() => _isProcessing = true);

    // Simulate processing
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isProcessing = false;
      _isDone = true;
      _result = {
        'totalRows': 45,
        'successRows': 43,
        'errorRows': 2,
        'errors': [
          {'sheet': 'MULTIPLE_CHOICE', 'row': 12, 'error': 'Đáp án không hợp lệ: "E"'},
          {'sheet': 'NUMERIC', 'row': 5, 'error': 'Không thể đọc giá trị số từ "abc"'},
        ],
      };
    });
  }

  void _downloadTemplate() {
    // Download template file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang tải file mẫu...')),
    );
  }
}

class _SheetGuide extends StatelessWidget {
  final String sheet;
  final String columns;
  final String example;

  const _SheetGuide({
    required this.sheet,
    required this.columns,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sheet, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
        Text(columns, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text('Ví dụ: $example', style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
