import 'package:flutter/material.dart';

class TextFormatter {
  // \n을 실제 줄바꿈으로 변환하는 위젯
  static Widget formatText(String text, {TextStyle? style, int? maxLines}) {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      spans.add(TextSpan(text: lines[i]));
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: style,
      ),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
    );
  }

  // 간단한 마크다운 스타일 적용 (굵은 글씨, 이모지 등)
  static Widget formatRichText(String text, {TextStyle? baseStyle, int? maxLines}) {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // 간단한 마크다운 파싱
      if (line.startsWith('✅ ') || line.startsWith('❌ ') || line.startsWith('💡 ')) {
        spans.add(TextSpan(
          text: line,
          style: baseStyle?.copyWith(fontWeight: FontWeight.w500),
        ));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        spans.add(TextSpan(
          text: line.substring(2, line.length - 2),
          style: baseStyle?.copyWith(fontWeight: FontWeight.bold),
        ));
      } else {
        spans.add(TextSpan(text: line, style: baseStyle));
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
    );
  }
}