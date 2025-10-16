
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // For saving images
import 'dart:ui' as ui; // For image manipulation in Dart

// Placeholder for ML Service (implemented later)
import 'ml_service.dart';

void main() {
  runApp(const NanoPicEditorApp());
}

class NanoPicEditorApp extends StatelessWidget {
  const NanoPicEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NanoPic Editor',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ImageEditorScreen(),
    );
  }
}

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  File? _selectedImage;
  ui.Image? _editedImage; // Store processed image as ui.Image for Flutter rendering
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final MLService _mlService = MLService();

  @override
  void initState() {
    super.initState();
    // Initialize ML models here if needed, or on first use
    _mlService.initializeModels(); // Placeholder
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _editedImage = null; // Clear previous edited state
        _isLoading = false;
      });
      _loadImageFileIntoUiImage(image.path); // Load initially selected image
    }
  }

  Future<void> _loadImageFileIntoUiImage(String path) async {
    final Uint8List bytes = await File(path).readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      _editedImage = frameInfo.image;
    });
  }

  Future<void> _processImage(Function(String) mlFunction) async {
    if (_selectedImage == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // Call the ML function, which will return the path to the processed image
      final String? resultImagePath = await mlFunction(_selectedImage!.path);
      if (resultImagePath != null) {
        await _loadImageFileIntoUiImage(resultImagePath); // Update UI with new image
        // Optionally update _selectedImage to point to the new image if it's the base for further edits
        _selectedImage = File(resultImagePath);
      }
    } catch (e) {
      print("Error processing image: $e");
      // Show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveImage() async {
    if (_editedImage == null) return;

    setState(() { _isLoading = true; });
    try {
      final ByteData? byteData = await _editedImage!.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List? pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final File saveFile = File('${directory.path}/edited_image_$timestamp.png');
        await saveFile.writeAsBytes(pngBytes);

        // In a real app, you'd save to the public gallery, requiring platform-specific code.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: ${saveFile.path}')),
        );
      }
    } catch (e) {
      print("Error saving image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NanoPic Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveImage,
            tooltip: 'Save Image',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isLoading ? null : () { /* Implement share functionality */ },
            tooltip: 'Share Image',
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _editedImage == null
                ? const Text('Select an image to start editing')
                : FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _editedImage!.width.toDouble(),
                      height: _editedImage!.height.toDouble(),
                      child: RawImage(image: _editedImage!),
                    ),
                  ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _pickImage,
                tooltip: 'Pick Image',
              ),
              const VerticalDivider(),
              _buildFeatureButton(
                icon: Icons.cut,
                label: 'Remove BG',
                onPressed: () => _processImage(_mlService.removeBackground),
              ),
              _buildFeatureButton(
                icon: Icons.filter_vintage,
                label: 'Pop Art',
                onPressed: () => _processImage((imagePath) => _mlService.applyFilter(imagePath, 'popart')),
              ),
              _buildFeatureButton(
                icon: Icons.blur_on,
                label: 'B&W',
                onPressed: () => _processImage((imagePath) => _mlService.applyFilter(imagePath, 'grayscale')),
              ),
              _buildFeatureButton(
                icon: Icons.invert_colors,
                label: 'Reverse',
                onPressed: () => _processImage((imagePath) => _mlService.applyFilter(imagePath, 'color_reverse')),
              ),
              _buildFeatureButton(
                icon: Icons.add_photo_alternate,
                label: 'Add Object',
                onPressed: () => _processImage(_mlService.addObject),
              ),
              _buildFeatureButton(
                icon: Icons.delete_forever,
                label: 'Remove Object',
                onPressed: () => _processImage(_mlService.removeObject),
              ),
              // Add more buttons for other features...
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: _isLoading ? null : onPressed,
          ),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}