import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Écran « À propos » : affiche le contenu du README embarqué dans l'app,
/// avec un rendu Markdown minimal (titres, listes, gras, code).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _red = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: _red,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('README.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Notice indisponible.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: _render(snapshot.data!),
          );
        },
      ),
    );
  }

  /// Rendu Markdown minimal, suffisant pour la notice.
  static List<Widget> _render(String markdown) {
    final widgets = <Widget>[];
    final codeBuffer = <String>[];
    var inCode = false;

    for (final raw in markdown.split('\n')) {
      final line = raw.trimRight();

      if (line.trimLeft().startsWith('```')) {
        if (inCode) {
          widgets.add(_codeBlock(codeBuffer.join('\n')));
          codeBuffer.clear();
        }
        inCode = !inCode;
        continue;
      }
      if (inCode) {
        codeBuffer.add(raw);
        continue;
      }

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(line.substring(2),
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: _red)),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(line.substring(3),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: TextStyle(height: 1.4)),
              Expanded(child: _inline(line.substring(2))),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _inline(line),
        ));
      }
    }
    return widgets;
  }

  /// Bloc de code délimité par ``` ```.
  static Widget _codeBlock(String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: SelectableText(
        code,
        style: const TextStyle(
            fontFamily: 'monospace', fontSize: 13, height: 1.4),
      ),
    );
  }

  /// Gère le **gras**, le `code` et les [liens](url) inline dans un paragraphe.
  static Widget _inline(String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|`(.+?)`|\[(.+?)\]\((.+?)\)');
    var index = 0;

    for (final m in pattern.allMatches(text)) {
      if (m.start > index) {
        spans.add(TextSpan(text: text.substring(index, m.start)));
      }
      if (m.group(1) != null) {
        spans.add(TextSpan(
            text: m.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold)));
      } else if (m.group(2) != null) {
        spans.add(TextSpan(
            text: m.group(2),
            style: const TextStyle(
                fontFamily: 'monospace', backgroundColor: Color(0x11000000))));
      } else {
        // Lien : on affiche simplement le libellé souligné en rouge.
        spans.add(TextSpan(
            text: m.group(3),
            style: const TextStyle(
                color: _red, decoration: TextDecoration.underline)));
      }
      index = m.end;
    }
    if (index < text.length) {
      spans.add(TextSpan(text: text.substring(index)));
    }

    return SelectableText.rich(
      TextSpan(
        style: const TextStyle(
            fontSize: 15, color: Colors.black87, height: 1.4),
        children: spans,
      ),
    );
  }
}
