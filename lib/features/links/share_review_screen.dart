import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';

class ShareReviewScreen extends StatefulWidget {
  final String? url;
  final String? text;
  const ShareReviewScreen({super.key, this.url, this.text});
  @override
  State<ShareReviewScreen> createState() => _ShareReviewScreenState();
}

class _ShareReviewScreenState extends State<ShareReviewScreen> {
  late final controller =
      TextEditingController(text: widget.url ?? widget.text);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Review Shared Content')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'URL or text')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final url = normalizeUrl(controller.text);
                  if (isValidUrl(url)) {
                    Navigator.pop(context, url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid URL')));
                  }
                },
                child: const Text('Save Link'),
              ),
            ],
          ),
        ),
      );
}
