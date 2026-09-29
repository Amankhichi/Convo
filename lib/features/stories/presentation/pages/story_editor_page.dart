import 'dart:io';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/stories/presentation/pages/story_preview_page.dart';
import 'package:flutter/material.dart';

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double strokeWidth;

  DrawnLine({
    required this.path,
    required this.color,
    required this.strokeWidth,
  });
}

class StoryTextItem {
  String text;
  Offset position;
  Color color;
  bool hasBackground;

  StoryTextItem({
    required this.text,
    required this.position,
    this.color = Colors.white,
    this.hasBackground = false,
  });
}

class StoryStickerItem {
  String emoji;
  Offset position;
  double scale;

  StoryStickerItem({
    required this.emoji,
    required this.position,
    this.scale = 1.0,
  });
}

class StoryEditorPage extends StatefulWidget {
  final String mediaPath;
  final String mediaType; // 'IMAGE' or 'VIDEO'

  const StoryEditorPage({
    super.key,
    required this.mediaPath,
    this.mediaType = 'IMAGE',
  });

  @override
  State<StoryEditorPage> createState() => _StoryEditorPageState();
}

class _StoryEditorPageState extends State<StoryEditorPage> {
  // Tools mode: null (none), 'text', 'draw', 'sticker', 'music'
  String? _activeTool;

  // Drawing state
  final List<DrawnLine> _lines = [];
  final List<DrawnLine> _undoLines = [];
  Color _selectedDrawColor = Colors.red;
  final double _drawStrokeWidth = 4.0;
  DrawnLine? _currentLine;

  // Text items
  final List<StoryTextItem> _textItems = [];
  final TextEditingController _textController = TextEditingController();
  Color _selectedTextColor = Colors.white;
  bool _textHasBg = false;

  // Sticker items
  final List<StoryStickerItem> _stickerItems = [];

  // Sound / Music metadata
  String? _selectedMusicTitle;

  final List<Color> _colorPalette = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.green,
    Colors.cyan,
    Colors.purple,
    Colors.pink,
  ];

  final List<String> _emojiStickers = [
    "😍", "🔥", "🎉", "❤️", "🚀", "💯", "⭐", "👑", "🎈", "✨", "😎", "🤩", "🎂", "💪", "👍"
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTextItem() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _textItems.add(
        StoryTextItem(
          text: _textController.text.trim(),
          position: const Offset(100, 250),
          color: _selectedTextColor,
          hasBackground: _textHasBg,
        ),
      );
      _textController.clear();
      _activeTool = null;
    });
  }

  void _openMusicSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Background Music", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.music_note, color: AppColors.primary),
                title: const Text("Acoustic Vibes - Summer Breeze"),
                onTap: () {
                  setState(() => _selectedMusicTitle = "Acoustic Vibes - Summer Breeze");
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: AppColors.primary),
                title: const Text("Lo-fi Beats - Midnight Chill"),
                onTap: () {
                  setState(() => _selectedMusicTitle = "Lo-fi Beats - Midnight Chill");
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear, color: Colors.red),
                title: const Text("No Music"),
                onTap: () {
                  setState(() => _selectedMusicTitle = null);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _proceedToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryPreviewPage(
          mediaPath: widget.mediaPath,
          mediaType: widget.mediaType,
          musicTitle: _selectedMusicTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Preview Image / Video background
          Positioned.fill(
            child: widget.mediaType == 'IMAGE'
                ? Image.file(File(widget.mediaPath), fit: BoxFit.contain)
                : Container(
                    color: const Color(0xFF181824),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam, size: 72, color: Colors.white70),
                          SizedBox(height: 8),
                          Text("Video Story Selected", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
          ),

          // Custom Drawing Canvas Overlay
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _activeTool == 'draw'
                  ? (details) {
                      setState(() {
                        _currentLine = DrawnLine(
                          path: [details.localPosition],
                          color: _selectedDrawColor,
                          strokeWidth: _drawStrokeWidth,
                        );
                        _lines.add(_currentLine!);
                      });
                    }
                  : null,
              onPanUpdate: _activeTool == 'draw'
                  ? (details) {
                      setState(() {
                        _currentLine?.path.add(details.localPosition);
                      });
                    }
                  : null,
              onPanEnd: _activeTool == 'draw'
                  ? (_) {
                      setState(() {
                        _currentLine = null;
                      });
                    }
                  : null,
              child: CustomPaint(
                painter: StoryDrawingPainter(lines: _lines),
              ),
            ),
          ),

          // Draggable Text Overlays
          ..._textItems.map(
            (item) => Positioned(
              left: item.position.dx,
              top: item.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    item.position += details.delta;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.hasBackground ? Colors.black.withOpacity(0.65) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.text,
                    style: TextStyle(
                      color: item.color,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      shadows: item.hasBackground ? null : const [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Draggable Sticker / Emoji Overlays
          ..._stickerItems.map(
            (item) => Positioned(
              left: item.position.dx,
              top: item.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    item.position += details.delta;
                  });
                },
                child: Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),

          // Music Metadata Tag if selected
          if (_selectedMusicTitle != null)
            Positioned(
              top: 100,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _selectedMusicTitle!,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // Top Header Bar Controls (Close, Tools bar: Text, Draw, Sticker, Music)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.text_fields, color: _activeTool == 'text' ? AppColors.primary : Colors.white),
                          onPressed: () => setState(() => _activeTool = _activeTool == 'text' ? null : 'text'),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: _activeTool == 'draw' ? AppColors.primary : Colors.white),
                          onPressed: () => setState(() => _activeTool = _activeTool == 'draw' ? null : 'draw'),
                        ),
                        IconButton(
                          icon: Icon(Icons.emoji_emotions_outlined, color: _activeTool == 'sticker' ? AppColors.primary : Colors.white),
                          onPressed: () => setState(() => _activeTool = _activeTool == 'sticker' ? null : 'sticker'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.music_note, color: Colors.white),
                          onPressed: _openMusicSelector,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Active Tool Control Panel (Text Input / Color Palette / Stickers Grid)
          if (_activeTool == 'text') _buildTextInputPanel(),
          if (_activeTool == 'draw') _buildDrawControlPanel(),
          if (_activeTool == 'sticker') _buildStickerControlPanel(),

          // Bottom Proceed / Send Button
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FloatingActionButton.extended(
                  backgroundColor: AppColors.primary,
                  onPressed: _proceedToPreview,
                  label: const Text("Next", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputPanel() {
    return Positioned(
      top: 90,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              style: TextStyle(color: _selectedTextColor, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Type text...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.format_color_fill, color: _textHasBg ? AppColors.primary : Colors.white),
                  onPressed: () => setState(() => _textHasBg = !_textHasBg),
                ),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colorPalette.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, idx) => GestureDetector(
                        onTap: () => setState(() => _selectedTextColor = _colorPalette[idx]),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: _colorPalette[idx],
                          child: _selectedTextColor == _colorPalette[idx]
                              ? const Icon(Icons.check, size: 14, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: _addTextItem,
                  child: const Text("Done"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawControlPanel() {
    return Positioned(
      bottom: 90,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.undo, color: Colors.white),
              onPressed: () {
                if (_lines.isNotEmpty) {
                  setState(() {
                    _undoLines.add(_lines.removeLast());
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () => setState(() {
                _lines.clear();
                _undoLines.clear();
              }),
            ),
            Expanded(
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorPalette.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, idx) => GestureDetector(
                    onTap: () => setState(() => _selectedDrawColor = _colorPalette[idx]),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: _colorPalette[idx],
                      child: _selectedDrawColor == _colorPalette[idx]
                          ? const Icon(Icons.check, size: 14, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerControlPanel() {
    return Positioned(
      bottom: 90,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _emojiStickers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (ctx, idx) => GestureDetector(
            onTap: () {
              setState(() {
                _stickerItems.add(
                  StoryStickerItem(
                    emoji: _emojiStickers[idx],
                    position: const Offset(150, 300),
                  ),
                );
                _activeTool = null;
              });
            },
            child: Text(_emojiStickers[idx], style: const TextStyle(fontSize: 36)),
          ),
        ),
      ),
    );
  }
}

class StoryDrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;

  StoryDrawingPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = line.strokeWidth;

      for (int i = 0; i < line.path.length - 1; i++) {
        canvas.drawLine(line.path[i], line.path[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StoryDrawingPainter oldDelegate) => true;
}
