import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';

/// Displays the file attachments of a task as a horizontally scrollable row.
///
/// Images are shown as small thumbnails; other files show a type icon + name.
/// Tapping any item opens it in the default browser / viewer via [url_launcher].
class TaskAttachmentsRow extends StatelessWidget {
  const TaskAttachmentsRow({super.key, required this.urls});

  final List<String> urls;

  static bool _isImage(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.gif') ||
        lower.contains('.webp');
  }

  static String _fileName(String url) {
    final decoded = Uri.decodeFull(url);
    final segments = decoded.split('/');
    return segments.isNotEmpty ? segments.last : url;
  }

  static IconData _icon(String url) {
    final ext = url.split('.').last.toLowerCase().split('?').first;
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.attach_file_rounded,
                    size: 13, color: AppColors.textMedium),
                const SizedBox(width: 4),
                Text(
                  '${urls.length} attachment${urls.length > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final url = urls[i];
                return GestureDetector(
                  onTap: () => _open(url),
                  child: _isImage(url)
                      ? _ImageThumb(url: url)
                      : _FileThumb(url: url),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image thumbnail ───────────────────────────────────────────────────────────

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FileFallback(url: url),
        loadingBuilder: (_, child, prog) => prog == null
            ? child
            : Container(
                width: 70,
                height: 70,
                color: AppColors.primaryLight,
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                ),
              ),
      ),
    );
  }
}

// ── File (non-image) thumbnail ────────────────────────────────────────────────

class _FileThumb extends StatelessWidget {
  const _FileThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return _FileFallback(url: url);
  }
}

class _FileFallback extends StatelessWidget {
  const _FileFallback({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final name = TaskAttachmentsRow._fileName(url);
    final short = name.length > 12 ? '${name.substring(0, 10)}…' : name;

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TaskAttachmentsRow._icon(url),
              color: AppColors.primary, size: 26),
          const SizedBox(height: 4),
          Text(
            short,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
