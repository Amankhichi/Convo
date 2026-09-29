import 'dart:io';
import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/network/api_client.dart';
import 'package:convo/features/stories/presentation/bloc/story_bloc.dart';
import 'package:convo/features/stories/presentation/bloc/story_event.dart';
import 'package:convo/features/stories/presentation/bloc/story_state.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryPreviewPage extends StatefulWidget {
  final String mediaPath;
  final String mediaType; // 'IMAGE' or 'VIDEO'
  final String? musicTitle;

  const StoryPreviewPage({
    super.key,
    required this.mediaPath,
    this.mediaType = 'IMAGE',
    this.musicTitle,
  });

  @override
  State<StoryPreviewPage> createState() => _StoryPreviewPageState();
}

class _StoryPreviewPageState extends State<StoryPreviewPage> {
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _uploadAndShareStory(BuildContext blocContext) async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final file = File(widget.mediaPath);
      if (!await file.exists()) {
        throw Exception("Media file not found at path: ${widget.mediaPath}");
      }

      final bytes = await file.readAsBytes();
      final filename = widget.mediaPath.split('/').last.split('\\').last;

      // 1. Upload raw media file via POST /api/media/upload
      final uploadRes = await sl<ApiClient>().postMultipart(
        ApiConfig.mediaUpload,
        queryParameters: {},
        fileBytes: bytes,
        fileFieldName: "file",
        filename: filename.isNotEmpty ? filename : "story_media.${widget.mediaType == 'VIDEO' ? 'mp4' : 'jpg'}",
      );

      String uploadedUrl = "";
      if (uploadRes is Map<String, dynamic>) {
        uploadedUrl = uploadRes["data"]?["mediaUrl"]?.toString() ??
            uploadRes["data"]?["fileUrl"]?.toString() ??
            uploadRes["mediaUrl"]?.toString() ??
            uploadRes["fileUrl"]?.toString() ??
            "";
      }

      if (uploadedUrl.isEmpty) {
        // Fallback sanitize if path is raw URL
        uploadedUrl = widget.mediaPath;
      }

      if (!mounted) return;

      // 2. Dispatch UploadStoryEvent to StoryBloc (POST /api/stories/upload)
      blocContext.read<StoryBloc>().add(
            UploadStoryEvent(
              mediaUrl: uploadedUrl,
              mediaType: widget.mediaType,
            ),
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMessage = "Upload failed: ${e.toString()}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StoryBloc>(),
      child: BlocConsumer<StoryBloc, StoryState>(
        listener: (context, state) {
          if (state is StoryUploadedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Story uploaded successfully!"),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is StoryError) {
            setState(() {
              _isUploading = false;
              _errorMessage = state.message;
            });
          }
        },
        builder: (blocContext, state) {
          final isBlocUploading = state is StoryUploadingState;

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: (_isUploading || isBlocUploading) ? null : () => Navigator.pop(context),
              ),
              title: const Text("Story Preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            body: Stack(
              children: [
                // Media Content Display
                Center(
                  child: widget.mediaType == 'IMAGE'
                      ? Image.file(File(widget.mediaPath), fit: BoxFit.contain)
                      : Container(
                          color: const Color(0xFF14141F),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.slow_motion_video, size: 80, color: Colors.white70),
                                SizedBox(height: 12),
                                Text("Ready to upload Video Story", style: TextStyle(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                ),

                // Music Badge Tag if selected
                if (widget.musicTitle != null)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            widget.musicTitle!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Error Banner
                if (_errorMessage != null)
                  Positioned(
                    top: 80,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom Action Bar (Share Button / Upload Progress)
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.black45,
                      child: Row(
                        children: [
                          if (_isUploading || isBlocUploading) ...[
                            const CircularProgressIndicator(color: AppColors.primary),
                            const SizedBox(width: 16),
                            const Text(
                              "Uploading Story...",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ] else ...[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Edit", style: TextStyle(color: Colors.white70, fontSize: 16)),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              icon: const Icon(Icons.send, color: Colors.white),
                              label: const Text(
                                "Share to Story",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              onPressed: () => _uploadAndShareStory(blocContext),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
