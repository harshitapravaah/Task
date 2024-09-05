import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clickable Hyperlink TextField',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HyperlinkTextFieldScreen(),
    );
  }
}

class HyperlinkTextFieldScreen extends StatefulWidget {
  @override
  _HyperlinkTextFieldScreenState createState() => _HyperlinkTextFieldScreenState();
}

class _HyperlinkTextFieldScreenState extends State<HyperlinkTextFieldScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _hyperlinkedText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clickable Hyperlink TextField'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField to paste text
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Enter or Paste Text with Hyperlinks',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _processText,
              child: Text('Process Text'),
            ),
            SizedBox(height: 20),
            // Display the text with hyperlinks as clickable
            if (_hyperlinkedText != null) ...[
              Text('Clickable Text:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildRichText(_hyperlinkedText!),
            ],
          ],
        ),
      ),
    );
  }

  // Process the input text and detect URLs
  void _processText() {
    final text = _controller.text;
    // Example regex to find URLs
    final urlRegex = RegExp(
        r"(https?:\/\/[^\s]+)",
        caseSensitive: false);

    if (urlRegex.hasMatch(text)) {
      setState(() {
        _hyperlinkedText = text;
      });
    } else {
      setState(() {
        _hyperlinkedText = null;
      });
    }
  }

  // Build the RichText widget to display clickable links
  Widget _buildRichText(String text) {
    final urlRegex = RegExp(
        r"(https?:\/\/[^\s]+)",
        caseSensitive: false);
    final matches = urlRegex.allMatches(text);
    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (var match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      final url = match.group(0);
      spans.add(
        TextSpan(
          text: url,
          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(url!),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return RichText(
      text: TextSpan(style: TextStyle(color: Colors.black), children: spans),
    );
  }

  // Launch the URL using url_launcher
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
