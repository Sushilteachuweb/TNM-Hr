import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';

class JobDescriptionEditor extends StatefulWidget {
  final String initialDescription;
  final String? initialDelta; // Delta JSON for re-editing

  const JobDescriptionEditor({
    super.key,
    this.initialDescription = '',
    this.initialDelta,
  });

  @override
  State<JobDescriptionEditor> createState() => _JobDescriptionEditorState();
}

class _JobDescriptionEditorState extends State<JobDescriptionEditor> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    if (widget.initialDelta != null && widget.initialDelta!.isNotEmpty) {
      // Load from Delta JSON to preserve formatting
      try {
        final deltaJson = jsonDecode(widget.initialDelta!);
        final doc = Document.fromJson(deltaJson);
        _controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        print('Error loading Delta: $e');
        _controller = QuillController.basic();
      }
    } else if (widget.initialDescription.isNotEmpty) {
      // Fallback: Strip HTML tags for plain text editing
      String plainText = widget.initialDescription
          .replaceAll(RegExp(r'<br>'), '\n')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&amp;', '&');
      
      final doc = Document()..insert(0, plainText);
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
    
    // Listen to selection changes to update toolbar button states
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _convertToHtml() {
    final delta = _controller.document.toDelta();
    final buffer = StringBuffer();
    
    bool inBulletList = false;
    bool inNumberedList = false;
    List<Map<String, dynamic>> currentLineSegments = [];
    
    final ops = delta.toList();
    
    for (int i = 0; i < ops.length; i++) {
      final op = ops[i];
      
      if (op.data is String) {
        String text = op.data as String;
        final attrs = op.attributes;
        
        // Split text that contains newlines
        if (text.contains('\n') && text != '\n') {
          // Text contains embedded newlines - split it
          final parts = text.split('\n');
          for (int j = 0; j < parts.length; j++) {
            if (parts[j].isNotEmpty) {
              // Add text segment
              bool hasBold = attrs != null && attrs.containsKey('bold');
              bool hasItalic = attrs != null && attrs.containsKey('italic');
              
              currentLineSegments.add({
                'text': parts[j],
                'bold': hasBold,
                'italic': hasItalic,
              });
            }
            
            // Add newline after each part except the last
            if (j < parts.length - 1) {
              // Process the accumulated line as regular text
              if (currentLineSegments.isNotEmpty) {
                for (var segment in currentLineSegments) {
                  if (segment['bold'] == true) buffer.write('<b>');
                  if (segment['italic'] == true) buffer.write('<i>');
                  buffer.write(segment['text']);
                  if (segment['italic'] == true) buffer.write('</i>');
                  if (segment['bold'] == true) buffer.write('</b>');
                }
                buffer.write('<br>');
                currentLineSegments = [];
              }
            }
          }
        } else if (text == '\n') {
          // This is a line break - check if it's a list item
          bool isBullet = attrs != null && attrs['list'] == 'bullet';
          bool isNumbered = attrs != null && attrs['list'] == 'ordered';
          
          // Handle list state transitions
          if (isBullet && !inBulletList) {
            if (inNumberedList) {
              buffer.write('</ol>');
              inNumberedList = false;
            }
            buffer.write('<ul>');
            inBulletList = true;
          } else if (isNumbered && !inNumberedList) {
            if (inBulletList) {
              buffer.write('</ul>');
              inBulletList = false;
            }
            buffer.write('<ol>');
            inNumberedList = true;
          } else if (!isBullet && !isNumbered && (inBulletList || inNumberedList)) {
            // Exiting list
            if (inBulletList) {
              buffer.write('</ul>');
              inBulletList = false;
            }
            if (inNumberedList) {
              buffer.write('</ol>');
              inNumberedList = false;
            }
          }
          
          // Output the line content
          if (currentLineSegments.isNotEmpty) {
            if (isBullet || isNumbered) {
              // Output as list item
              buffer.write('<li>');
              for (var segment in currentLineSegments) {
                if (segment['bold'] == true) buffer.write('<b>');
                if (segment['italic'] == true) buffer.write('<i>');
                buffer.write(segment['text']);
                if (segment['italic'] == true) buffer.write('</i>');
                if (segment['bold'] == true) buffer.write('</b>');
              }
              buffer.write('</li>');
            } else {
              // Output as regular text
              for (var segment in currentLineSegments) {
                if (segment['bold'] == true) buffer.write('<b>');
                if (segment['italic'] == true) buffer.write('<i>');
                buffer.write(segment['text']);
                if (segment['italic'] == true) buffer.write('</i>');
                if (segment['bold'] == true) buffer.write('</b>');
              }
              buffer.write('<br>');
            }
            currentLineSegments = [];
          }
        } else {
          // Regular text - accumulate with formatting
          bool hasBold = attrs != null && attrs.containsKey('bold');
          bool hasItalic = attrs != null && attrs.containsKey('italic');
          
          currentLineSegments.add({
            'text': text,
            'bold': hasBold,
            'italic': hasItalic,
          });
        }
      }
    }
    
    // Handle any remaining text
    if (currentLineSegments.isNotEmpty) {
      // Close any open lists
      if (inBulletList) {
        buffer.write('</ul>');
        inBulletList = false;
      }
      if (inNumberedList) {
        buffer.write('</ol>');
        inNumberedList = false;
      }
      
      for (var segment in currentLineSegments) {
        if (segment['bold'] == true) buffer.write('<b>');
        if (segment['italic'] == true) buffer.write('<i>');
        buffer.write(segment['text']);
        if (segment['italic'] == true) buffer.write('</i>');
        if (segment['bold'] == true) buffer.write('</b>');
      }
    }
    
    // Close any remaining lists
    if (inBulletList) buffer.write('</ul>');
    if (inNumberedList) buffer.write('</ol>');
    
    final html = buffer.toString();
    print('🔍 Generated HTML length: ${html.length}');
    print('🔍 Full HTML: $html');
    return html;
  }

  void _saveAndReturn() {
    final htmlText = _convertToHtml();
    final deltaJson = jsonEncode(_controller.document.toDelta().toJson());
    
    print('📝 Generated HTML: $htmlText');
    print('📝 Generated Delta: $deltaJson');
    
    // Return both HTML and Delta
    Navigator.pop(context, {
      'html': htmlText,
      'delta': deltaJson,
    });
  }

  bool _isFormatActive(Attribute attribute) {
    final style = _controller.getSelectionStyle();
    if (attribute.key == 'list') {
      // For lists, check if the specific list type matches
      final listValue = style.attributes['list'];
      // Attribute.ul.value is 'bullet', Attribute.ol.value is 'ordered'
      return listValue?.value == attribute.value;
    }
    return style.attributes.containsKey(attribute.key);
  }

  void _toggleFormat(Attribute attribute) {
    final isActive = _isFormatActive(attribute);
    if (isActive) {
      _controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      _controller.formatSelection(attribute);
    }
  }

  void _toggleList(Attribute attribute) {
    final style = _controller.getSelectionStyle();
    final currentListValue = style.attributes['list'];
    
    // Check if this specific list type is active
    final isActive = currentListValue?.value == attribute.value;
    
    if (isActive) {
      // Remove list formatting
      _controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      // Apply list formatting (this will replace any existing list type)
      _controller.formatSelection(attribute);
    }
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
    String? tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        onPressed: onPressed,
        tooltip: tooltip,
        color: isActive ? AppColors.primary : AppColors.textPrimary,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Description',
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveAndReturn,
            icon: const Icon(Icons.check, color: Colors.white),
            label: Text(
              'Save',
              style: AppTextStyles.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Toolbar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolbarButton(
                    icon: Icons.format_bold,
                    tooltip: 'Bold',
                    isActive: _isFormatActive(Attribute.bold),
                    onPressed: () => _toggleFormat(Attribute.bold),
                  ),
                  _buildToolbarButton(
                    icon: Icons.format_italic,
                    tooltip: 'Italic',
                    isActive: _isFormatActive(Attribute.italic),
                    onPressed: () => _toggleFormat(Attribute.italic),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.divider,
                  ),
                  const SizedBox(width: 8),
                  _buildToolbarButton(
                    icon: Icons.format_list_bulleted,
                    tooltip: 'Bullet List',
                    isActive: _isFormatActive(Attribute.ul),
                    onPressed: () => _toggleList(Attribute.ul),
                  ),
                  _buildToolbarButton(
                    icon: Icons.format_list_numbered,
                    tooltip: 'Numbered List',
                    isActive: _isFormatActive(Attribute.ol),
                    onPressed: () => _toggleList(Attribute.ol),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.divider,
                  ),
                  const SizedBox(width: 8),
                  _buildToolbarButton(
                    icon: Icons.undo,
                    tooltip: 'Undo',
                    isActive: false,
                    onPressed: () {
                      if (_controller.hasUndo) {
                        _controller.undo();
                      }
                    },
                  ),
                  _buildToolbarButton(
                    icon: Icons.redo,
                    tooltip: 'Redo',
                    isActive: false,
                    onPressed: () {
                      if (_controller.hasRedo) {
                        _controller.redo();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          
          // Editor with hint overlay
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Focus the editor when tapping anywhere in the area
                _focusNode.requestFocus();
              },
              child: Container(
                color: AppColors.surface,
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Editor (always present)
                    SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      child: QuillEditor.basic(
                        controller: _controller,
                        focusNode: _focusNode,
                      ),
                    ),
                    
                    // Hint text overlay (only when empty, non-interactive)
                    if (_controller.document.isEmpty())
                      IgnorePointer(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Start typing your job description here...\n\n'
                            'Tips:\n'
                            '• Select text to apply Bold or Italic\n'
                            '• Use bullet or numbered lists for requirements\n'
                            '• Tap formatting buttons to toggle styles',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textHint,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
