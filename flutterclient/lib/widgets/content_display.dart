import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../models/chat_message.dart';
import '../constants/websocket_commands.dart';

/// Widget for displaying different types of content
class ContentDisplay extends StatelessWidget {
  final ContentItem content;

  const ContentDisplay({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    switch (content.type) {
      case ContentTypes.text:
        return _buildTextContent(context);
      case ContentTypes.image:
        return _buildImageContent(context);
      case ContentTypes.audio:
        return _buildAudioContent(context);
      case ContentTypes.embeddedResource:
        return _buildEmbeddedResourceContent(context);
      default:
        return _buildUnknownContent(context);
    }
  }

  /// Build text content widget with markdown support
  Widget _buildTextContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MarkdownBody(
        data: content.text ?? '',
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: Theme.of(context).textTheme.bodyMedium,
          code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
          codeblockDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrl(Uri.parse(href));
          }
        },
      ),
    );
  }

  /// Build image content widget
  Widget _buildImageContent(BuildContext context) {
    if (content.data == null) {
      return _buildErrorContent(context, '图片数据为空');
    }

    try {
      final imageBytes = base64Decode(content.data!);
      return Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorContent(context, '图片加载失败');
            },
          ),
        ),
      );
    } catch (error) {
      return _buildErrorContent(context, '图片格式错误');
    }
  }

  /// Build audio content widget
  Widget _buildAudioContent(BuildContext context) {
    if (content.data == null) {
      return _buildErrorContent(context, '音频数据为空');
    }

    return AudioPlayerWidget(
      audioData: content.data!,
      mimeType: content.mimeType,
    );
  }

  /// Build embedded resource content widget
  Widget _buildEmbeddedResourceContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attachment,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '嵌入资源',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (content.uri != null) ...[
            Text(
              'URI: ${content.uri}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
          ],
          if (content.mimeType != null) ...[
            Text(
              'MIME Type: ${content.mimeType}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
          ],
          if (content.uri != null)
            ElevatedButton.icon(
              onPressed: () => _launchUrl(content.uri!),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('打开'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  /// Build unknown content type widget
  Widget _buildUnknownContent(BuildContext context) {
    return _buildErrorContent(context, '未知内容类型: ${content.type}');
  }

  /// Build error content widget
  Widget _buildErrorContent(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Launch URL
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (error) {
      // debugPrint('Failed to launch URL: $error');
    }
  }
}

/// Audio player widget for playing audio content
class AudioPlayerWidget extends StatefulWidget {
  final String audioData;
  final String? mimeType;

  const AudioPlayerWidget({
    super.key,
    required this.audioData,
    this.mimeType,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  Future<void> _playPause() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Decode base64 audio data
        final audioBytes = base64Decode(widget.audioData);
        await _audioPlayer.play(BytesSource(audioBytes));
      }
    } catch (error) {
      // debugPrint('Audio playback error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('音频播放失败: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.audiotrack,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '音频文件',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (widget.mimeType != null) ...[
                const Spacer(),
                Text(
                  widget.mimeType!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              IconButton(
                onPressed: _isLoading ? null : _playPause,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              Expanded(
                child: Column(
                  children: [
                    Slider(
                      value: _position.inMilliseconds.toDouble(),
                      max: _duration.inMilliseconds.toDouble(),
                      onChanged: (value) async {
                        await _audioPlayer.seek(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
