import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventhub/models/event.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/event_repository.dart';
import 'package:intl/intl.dart';

const _kCategories = [
  'Music', 'Technology', 'Sports', 'Food', 'Art',
  'Business', 'Education', 'Health', 'Other',
];

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _cityController = TextEditingController();
  String _selectedCategory = 'Music';
  DateTime? _startAt;
  DateTime? _endAt;
  bool _isLoading = false;

  // Banner image state
  Uint8List? _bannerBytes;
  String? _bannerExtension;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null) return;

    final picked = await picker.pickImage(
      source: result,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final ext = picked.path.split('.').last.toLowerCase();
    setState(() {
      _bannerBytes = bytes;
      _bannerExtension = ext == 'jpg' ? 'jpeg' : ext;
    });
  }

  void _removeBanner() => setState(() {
        _bannerBytes = null;
        _bannerExtension = null;
      });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _startAt == null ||
        _endAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select dates.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authControllerProvider).value!;
      String? bannerUrl;

      // Upload banner if selected
      if (_bannerBytes != null) {
        setState(() => _isUploadingImage = true);
        try {
          bannerUrl = await ref.read(eventRepositoryProvider).uploadBannerImage(
                organizerId: user.id,
                bytes: _bannerBytes!,
                extension: _bannerExtension ?? 'jpeg',
              );
        } catch (_) {
          // Banner upload failure is non-fatal
        } finally {
          if (mounted) setState(() => _isUploadingImage = false);
        }
      }

      final newEvent = Event(
        id: '',
        organizerId: user.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        venue: _venueController.text.trim(),
        city: _cityController.text.trim(),
        startAt: _startAt!,
        endAt: _endAt!,
        category: _selectedCategory,
        status: 'draft',
        bannerUrl: bannerUrl,
      );

      await ref.read(eventRepositoryProvider).createEvent(newEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Event created successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => isStart ? _startAt = dt : _endAt = dt);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM d, y • h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Banner Image Picker ──────────────────────────────
              GestureDetector(
                onTap: _pickBanner,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.4),
                        width: 1.5),
                    image: _bannerBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_bannerBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _bannerBytes != null
                      ? Stack(
                          children: [
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.55),
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                  padding: EdgeInsets.zero,
                                  onPressed: _removeBanner,
                                ),
                              ),
                            ),
                            if (_isUploadingImage)
                              const Center(child: CircularProgressIndicator()),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text('Tap to add event banner',
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant)),
                            Text('(Optional — gallery or camera)',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6))),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Title ───────────────────────────────────────────
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title *',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // ── Description ─────────────────────────────────────
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              // ── Venue & City ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _venueController,
                      decoration: InputDecoration(
                        labelText: 'Venue *',
                        prefixIcon: const Icon(Icons.place_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'City *',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Category Dropdown ────────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: _kCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 14),

              // ── Date & Time ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.event, size: 18),
                      label: Text(
                        _startAt == null
                            ? 'Start Date/Time *'
                            : fmt.format(_startAt!),
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        foregroundColor: _startAt != null
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => _pickDateTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.event_available, size: 18),
                      label: Text(
                        _endAt == null
                            ? 'End Date/Time *'
                            : fmt.format(_endAt!),
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        foregroundColor: _endAt != null
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => _pickDateTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Submit ───────────────────────────────────────────
              FilledButton.icon(
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.add_circle_outline),
                label: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Create Event',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLoading ? null : _submit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
