import 'dart:async';
import 'dart:math'; // Added for min function
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dart_rfb/dart_rfb.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
      title: 'Dart RFB Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VncViewerPage(),
    );
}

class VncViewerPage extends StatefulWidget {
  const VncViewerPage({super.key});

  @override
  State<VncViewerPage> createState() => _VncViewerPageState();
}

class _VncViewerPageState extends State<VncViewerPage> {
  final RemoteFrameBufferClient _client = RemoteFrameBufferClient();
  final GlobalKey _vncContainerKey = GlobalKey(); // Added GlobalKey

  // Controllers for TextFields
  final TextEditingController _hostController =
      TextEditingController(text: '127.0.0.1');
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isConnected = false;
  bool _isConnecting = false;
  String _statusMessage = 'Enter connection details and press Connect.';
  
  // Store the latest image data
  Uint8List? _imageData;
  ui.Image? _uiImage;
  int _frameBufferWidth = 0;
  int _frameBufferHeight = 0;
  bool _processingImage = false;
  bool _useTestImage = false; // Toggle between test image and actual VNC image
  
  @override
  void initState() {
    super.initState();
    // Do not automatically connect, wait for button press
  }
  
  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _hostController.dispose();
    _portController.dispose();
    _passwordController.dispose();
    _client.close();
    super.dispose();
  }
  
  Future<void> _disconnectFromServer() async {
    await _client.close();
    setState(() {
      _isConnected = false;
      _isConnecting = false;
      _imageData = null;
      _uiImage?.dispose();
      _uiImage = null;
      _frameBufferWidth = 0;
      _frameBufferHeight = 0;
      _statusMessage = 'Disconnected. Enter connection details and press Connect.';
    });
  }

  Future<void> _connectToServer() async {
    if (_isConnecting) return;

    final String host = _hostController.text.trim();
    if (host.isEmpty) {
      setState(() {
        _statusMessage = 'Host cannot be empty.';
      });
      return;
    }

    final String portString = _portController.text.trim();
    int? port;
    if (portString.isNotEmpty) {
      port = int.tryParse(portString);
      if (port == null) {
        setState(() {
          _statusMessage = 'Invalid port number.';
        });
        return;
      }
    }

    final String password = _passwordController.text;

    setState(() {
      _isConnecting = true;
      _statusMessage = 'Connecting to $host${port != null ? ':$port' : ''}...';
      _imageData = null; // Clear previous image data
      _uiImage?.dispose();
      _uiImage = null;
      _frameBufferWidth = 0;
      _frameBufferHeight = 0;
    });
    
    try {
      // Ensure client is reset or new if previously connected/failed
      // This might involve re-initializing _client or ensuring its state is clean
      // For simplicity, we assume _client.connect handles reconnection logic correctly.
      // If not, you might need:
      // if (_client.isConnected()) await _client.close();
      // _client = RemoteFrameBufferClient(); // Or some reset method

      await _client.connect(
        hostname: host,
        port: port ?? 5900, // Default VNC port
        password: password,
      );
      
      // Set up update stream listener
      _client.updateStream.listen((final update) {
        _processUpdate(update);
        
        // Request next update after processing the current one
        _client.requestUpdate();
      });
      
      // Start handling incoming messages
      _client.handleIncomingMessages();
      
      // Request initial update
      _client.requestUpdate();
      
      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _statusMessage = 'Connected';
      });
      
      // Get framebuffer dimensions from config
      if (_client.config.isSome()) {
        final config = _client.config.getOrElse(() => throw Exception('No config'));
        setState(() {
          _frameBufferWidth = config.frameBufferWidth;
          _frameBufferHeight = config.frameBufferHeight;
        });
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _statusMessage = 'Connection failed: $e';
      });
      print('Connection error: $e');
    }
  }
  
  void _processUpdate(final RemoteFrameBufferClientUpdate update) {
    // If we don't have dimensions yet, we can't process updates
    if (_frameBufferWidth == 0 || _frameBufferHeight == 0) {
      return;
    }
    
    // Debug information
    print('Received update with ${update.rectangles.length} rectangles');
    
    // Create full framebuffer image if it doesn't exist yet
    if (_imageData == null) {
      _imageData = Uint8List(_frameBufferWidth * _frameBufferHeight * 4);
      // Initialize with black background
      for (int i = 0; i < _imageData!.length; i += 4) {
        _imageData![i] = 0;     // R
        _imageData![i + 1] = 0; // G
        _imageData![i + 2] = 0; // B
        _imageData![i + 3] = 255; // A
      }
    }
    
    // Process each rectangle in the update
    for (final rectangle in update.rectangles) {
      final int rectX = rectangle.x;
      final int rectY = rectangle.y;
      final int rectWidth = rectangle.width;
      final int rectHeight = rectangle.height;
      
      print('Rectangle: x=$rectX, y=$rectY, width=$rectWidth, height=$rectHeight, encoding=${rectangle.encodingType}');
      
      // For raw encoding, we can directly use the pixel data
      if (rectangle.encodingType == const RemoteFrameBufferEncodingType.raw()) {
        final ByteData pixelData = rectangle.byteData;
        
        // Update the corresponding part of our framebuffer
        for (int y = 0; y < rectHeight; y++) {
          for (int x = 0; x < rectWidth; x++) {
            final int srcPos = (y * rectWidth + x) * 4;
            final int destPos = ((rectY + y) * _frameBufferWidth + (rectX + x)) * 4;
            
            if (srcPos + 3 < pixelData.lengthInBytes && 
                destPos + 3 < _imageData!.length) {
              // BGRA to RGBA conversion
              _imageData![destPos] = pixelData.getUint8(srcPos + 2);     // R
              _imageData![destPos + 1] = pixelData.getUint8(srcPos + 1); // G
              _imageData![destPos + 2] = pixelData.getUint8(srcPos);     // B
              _imageData![destPos + 3] = 255; // A - Force fully opaque
            }
          }
        }
      } else if (rectangle.encodingType == const RemoteFrameBufferEncodingType.copyRect()) {
        // Handle copyRect encoding if needed
        print('CopyRect encoding not implemented yet');
      }
    }
    
    // Convert the image data to a UI image
    _convertImageData();
  }
  
  // Convert the raw RGBA data to a UI image
  Future<void> _convertImageData() async {
    if (_imageData == null || _processingImage) {
      return;
    }
    
    _processingImage = true;
    print('Converting image data to UI image...');
    
    try {
      // For debugging, let's create a solid red image
      final bool useRedImage = _useTestImage; // Use test image if toggled
      
      if (useRedImage) {
        print('Using red test image');
        final Uint8List redImage = Uint8List(_frameBufferWidth * _frameBufferHeight * 4);
        for (int i = 0; i < redImage.length; i += 4) {
          redImage[i] = 255;     // R (red)
          redImage[i + 1] = 0;   // G
          redImage[i + 2] = 0;   // B
          redImage[i + 3] = 255; // A
        }
        
        final Completer<ui.Image> completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(
          redImage,
          _frameBufferWidth,
          _frameBufferHeight,
          ui.PixelFormat.rgba8888,
          completer.complete,
        );
        
        final ui.Image image = await completer.future;
        
        setState(() {
          // Dispose of the old image if it exists
          _uiImage?.dispose();
          _uiImage = image;
          _processingImage = false;
          print('Red test image created successfully');
        });
      } else {
        // Use the actual image data
        print('Using actual VNC image data');
        
        // Force all pixels to be opaque
        for (int i = 0; i < _imageData!.length; i += 4) {
          _imageData![i + 3] = 255; // Set alpha to 255 (fully opaque)
        }
        
        print('All pixels set to opaque');
        
        final Completer<ui.Image> completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(
          _imageData!,
          _frameBufferWidth,
          _frameBufferHeight,
          ui.PixelFormat.rgba8888,
          completer.complete,
        );
        
        final ui.Image image = await completer.future;
        
        setState(() {
          // Dispose of the old image if it exists
          _uiImage?.dispose();
          _uiImage = image;
          _processingImage = false;
          print('VNC image created successfully');
        });
      }
    } catch (e) {
      print('Error converting image data: $e');
      _processingImage = false;
      
      // Try with a red test image as fallback
      try {
        print('Trying with red test image as fallback');
        final Uint8List redImage = Uint8List(_frameBufferWidth * _frameBufferHeight * 4);
        for (int i = 0; i < redImage.length; i += 4) {
          redImage[i] = 255;     // R (red)
          redImage[i + 1] = 0;   // G
          redImage[i + 2] = 0;   // B
          redImage[i + 3] = 255; // A
        }
        
        final Completer<ui.Image> completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(
          redImage,
          _frameBufferWidth,
          _frameBufferHeight,
          ui.PixelFormat.rgba8888,
          completer.complete,
        );
        
        final ui.Image image = await completer.future;
        
        setState(() {
          // Dispose of the old image if it exists
          _uiImage?.dispose();
          _uiImage = image;
          _processingImage = false;
          print('Fallback red test image created successfully');
        });
      } catch (e2) {
        print('Error creating fallback image: $e2');
        _processingImage = false;
      }
    }
  }
  
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart RFB Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'Host',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isConnecting && !_isConnected,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isConnecting && !_isConnected,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password (optional)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !_isConnecting && !_isConnected,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isConnecting
                  ? null
                  : (_isConnected ? _disconnectFromServer : _connectToServer),
              child: Text(_isConnecting
                  ? 'Connecting...'
                  : (_isConnected ? 'Disconnect' : 'Connect')),
            ),
            const SizedBox(height: 8),
            // Status Message
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // VNC Viewer Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.black, // Background for VNC area
                ),
                child: Center(
                  child: _isConnected && _uiImage != null
                      ? _buildVncView()
                      : _isConnecting
                          ? const CircularProgressIndicator()
                          : Text(
                              _isConnected ? 'Waiting for image...' : 'Not Connected',
                              style: const TextStyle(color: Colors.white),
                            ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Toggle Test Image Button (optional, kept for debugging)
            if (_isConnected) // Only show if connected
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _useTestImage = !_useTestImage;
                    _convertImageData(); // Force image regeneration
                  });
                },
                child: Text(_useTestImage ? 'Show VNC Image' : 'Show Test Image'),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVncView() {
    if (_imageData == null || _frameBufferWidth == 0 || _frameBufferHeight == 0) {
      return const Text('No image data available');
    }
    
    // Create a simpler approach using Image.memory
    return Container(
      key: _vncContainerKey, // Assign GlobalKey to the Container
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Listener(
        onPointerDown: (final event) {
          // Handle mouse button press
          if (event.buttons == 1) { // Left button
            _sendPointerEvent(
              event.position, 
              button1Down: true,
            );
          } else if (event.buttons == 2) { // Right button
            _sendPointerEvent(
              event.position, 
              button3Down: true,
            );
          } else if (event.buttons == 4) { // Middle button
            _sendPointerEvent(
              event.position, 
              button2Down: true,
            );
          }
        },
        onPointerUp: (final event) {
          // Handle mouse button release
          _sendPointerEvent(
            event.position, 
            button1Down: false,
            button2Down: false,
            button3Down: false,
          );
        },
        onPointerMove: (final event) {
          // Handle mouse movement with buttons pressed
          final bool button1Down = (event.buttons & 1) != 0;
          final bool button2Down = (event.buttons & 4) != 0;
          final bool button3Down = (event.buttons & 2) != 0;
          
          _sendPointerEvent(
            event.position,
            button1Down: button1Down,
            button2Down: button2Down,
            button3Down: button3Down,
          );
        },
        onPointerHover: (final event) {
          // Handle mouse hover
          _sendPointerEvent(event.position);
        },
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _frameBufferWidth.toDouble(),
              height: _frameBufferHeight.toDouble(),
              child: _buildImageWidget(),
            ),
          ),
        ),
      ),
    );
  }
  
  // Store the last pointer position for use in onPanEnd
  Offset? _lastPointerPosition;
  
  // Track button states
  bool _button1Down = false;
  bool _button2Down = false;
  bool _button3Down = false;
  
  // Helper method to send pointer events to the VNC server
  void _sendPointerEvent(
    final Offset globalPosition, {
    final bool? button1Down,
    final bool? button2Down,
    final bool? button3Down,
  }) {
    // Initial checks and button state updates
    if (!_isConnected || _frameBufferWidth == 0 || _frameBufferHeight == 0) return;
    if (button1Down != null) _button1Down = button1Down;
    if (button2Down != null) _button2Down = button2Down;
    if (button3Down != null) _button3Down = button3Down;
    
    // Use the GlobalKey to get the RenderBox of the specific container
    final RenderBox? containerRenderBox =
        _vncContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (containerRenderBox == null) {
      print('VNC Container RenderBox not found');
      return;
    }

    final Offset localPositionInContainer = containerRenderBox.globalToLocal(globalPosition);
    final Size containerSize = containerRenderBox.size;

    // Calculate the scale factor used by FittedBox.contain
    // This is the scale from VNC native size to displayed size.
    final double scaleToFit = min(
      containerSize.width / _frameBufferWidth,
      containerSize.height / _frameBufferHeight,
    );

    final double displayedWidth = _frameBufferWidth * scaleToFit;
    final double displayedHeight = _frameBufferHeight * scaleToFit;

    // Calculate the offset of the FittedBox content (the displayed image)
    // within the container, due to Center widget.
    final double offsetX = (containerSize.width - displayedWidth) / 2;
    final double offsetY = (containerSize.height - displayedHeight) / 2;

    // Adjust localPositionInContainer to be relative to the top-left of the actual displayed image
    final double tapOnDisplayedImageX = localPositionInContainer.dx - offsetX;
    final double tapOnDisplayedImageY = localPositionInContainer.dy - offsetY;

    // If the tap is outside the bounds of the displayed image (i.e., in the padding), ignore it.
    if (tapOnDisplayedImageX < 0 ||
        tapOnDisplayedImageX >= displayedWidth ||
        tapOnDisplayedImageY < 0 ||
        tapOnDisplayedImageY >= displayedHeight) {
      // Optionally log this, or handle as "click outside active area"
      // print('Tap in padding area, ignoring.');
      return;
    }

    // Scale the tap coordinates on the displayed image back to the original framebuffer coordinates.
    // The inverse of scaleToFit is the scale from displayed size back to VNC native size.
    final int x = (tapOnDisplayedImageX / scaleToFit).round().clamp(0, _frameBufferWidth - 1);
    final int y = (tapOnDisplayedImageY / scaleToFit).round().clamp(0, _frameBufferHeight - 1);
    
    // Store the original global position for any other use cases (like onPanEnd, though it's not fully implemented here)
    _lastPointerPosition = globalPosition;

    // Send pointer event to server
    _client.sendPointerEvent(
      pointerEvent: RemoteFrameBufferClientPointerEvent(
        button1Down: _button1Down,
        button2Down: _button2Down,
        button3Down: _button3Down,
        button4Down: false,
        button5Down: false,
        button6Down: false,
        button7Down: false,
        button8Down: false,
        x: x,
        y: y,
      ),
    );
    
    print('Sent pointer event: x=$x, y=$y, button1=$_button1Down, button3=$_button3Down');
  }
  
  // Helper method to build the image widget
  Widget _buildImageWidget() {
    if (_uiImage != null) {
      print('Using UI image for display');
      return Stack(
        children: [
          // Display the VNC screen
          RawImage(
            image: _uiImage,
            width: _frameBufferWidth.toDouble(),
            height: _frameBufferHeight.toDouble(),
            fit: BoxFit.contain,
          ),
          
          // Add a debug overlay
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black.withOpacity(0.7),
              child: Text(
                'VNC Screen: $_frameBufferWidth x $_frameBufferHeight',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    } else {
      // Show a placeholder while the image is being processed
      return Container(
        width: _frameBufferWidth.toDouble(),
        height: _frameBufferHeight.toDouble(),
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
