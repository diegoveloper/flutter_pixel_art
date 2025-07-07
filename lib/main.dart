import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Art Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PixelArtPage(title: 'Pixel Art Converter'),
    );
  }
}

class PixelArtPage extends StatefulWidget {
  const PixelArtPage({super.key, required this.title});

  final String title;

  @override
  State<PixelArtPage> createState() => _PixelArtPageState();
}

class _PixelArtPageState extends State<PixelArtPage> {
  // Sample image URLs for testing
  final imageUrl1 =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrh7NSoAFrClf1qe79cPAz-XKGWYxwJYfhqA&s';
  final imageUrl2 =
      'https://static.wikia.nocookie.net/doblaje-fanon/images/0/0f/Ñoño_animado.png/revision/latest?cb=20211113202850&path-prefix=es';
  final imageUrl3 =
      'https://www.pngplay.com/wp-content/uploads/11/Pikachu-Pokemon-Transparent-Images.png';

  final imageUrl4 =
      'https://lh3.googleusercontent.com/gps-cs-s/AC9h4npGYfST0JNslivofuasn4vk5nBlCtmJ_Qx13hX71WkEQop5gr0fz9W6_2kWxJQ8Qby9oRjL86hBv6_44AlyhfNJyEOB7UuOQhl0Gph2Bz9vYgzdXhpHjdUQmgmRxtwF6HKHl7l3ng=s680-w680-h510';

  Uint8List? imageBytes;
  Uint8List? pixelatedImageBytes;

  int pixelSize = 8;

  @override
  void initState() {
    super.initState();
    _downloadImage(imageUrl1);
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        setState(() {
          imageBytes = response.bodyBytes;
          pixelatedImageBytes = null;
        });
        _convertToPixelArt();
      } else {
        debugPrint('Error downloading image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _convertToPixelArt() {
    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image has been downloaded'),
        ),
      );
      return;
    }

    final myImageObject = _decodeImage(imageBytes!);

    final newWidth = myImageObject.width ~/ pixelSize;
    final newHeight = myImageObject.height ~/ pixelSize;

    // Resize to create pixelated effect without changing colors
    img.Image resized = img.copyResize(
      myImageObject,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.nearest,
    );

    img.Image pixelated = img.copyResize(
      resized,
      width: newWidth * pixelSize,
      height: newHeight * pixelSize,
      interpolation: img.Interpolation.nearest,
    );

    setState(() {
      pixelatedImageBytes = img.encodePng(pixelated); // Preserve transparency
    });
  }

  img.Image _decodeImage(Uint8List bytes) {
    return img.decodeImage(bytes)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            // Replace the image with the selected one
            onPressed: () => _downloadImage(imageUrl1),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imageBytes != null
                  ? Expanded(
                      child: Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
              pixelatedImageBytes != null
                  ? Expanded(
                      child: Image.memory(
                        pixelatedImageBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Spacer(),
              const SizedBox(height: 20),
              Text('Pixel size: $pixelSize'),
              Slider(
                value: pixelSize.toDouble(),
                min: 1,
                max: 32,
                divisions: 31,
                onChanged: (value) {
                  setState(() {
                    pixelSize = value.toInt();
                    _convertToPixelArt();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
