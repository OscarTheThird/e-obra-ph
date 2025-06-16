// screens/artist/create_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
// Conditional import for web-only functionality
import 'dart:html' as html show FileUploadInputElement, FileReader;
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/artwork_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _mediumController = TextEditingController();
  final _dimensionsController = TextEditingController();
  
  String _selectedArtType = 'Painting';
  String _selectedArtStyle = 'Abstract';
  bool _isAvailable = true;
  List<dynamic> _selectedImages = []; // Changed to dynamic to handle both File and Uint8List
  List<String> _imageNames = []; // Store image names for web
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  final List<String> _artTypes = [
    'Painting',
    'Pottery',
    'Sculpture',
    'Digital Art',
    'Photography',
    'Drawing',
    'Mixed Media',
    'Jewelry',
    'Textile Art',
    'Glass Art',
  ];

  final List<String> _artStyles = [
    'Abstract',
    'Realistic',
    'Contemporary',
    'Traditional',
    'Modern',
    'Impressionist',
    'Expressionist',
    'Minimalist',
    'Pop Art',
    'Street Art',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _mediumController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: _isLoading 
            ? null 
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              _buildImageUploadSection(),
              const SizedBox(height: 24),
              
              // Loading Progress
              if (_isLoading) _buildUploadProgress(),
              
              // Form Fields
              _buildFormFields(),
              
              const SizedBox(height: 24),
              
              // Create Post Button
              _buildCreatePostButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add Photos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_selectedImages.length}/5',
              style: TextStyle(
                color: _selectedImages.length >= 5 ? Colors.red : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + (_selectedImages.length < 5 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return _buildAddPhotoButton();
              }
              return _buildImagePreview(index);
            },
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Add up to 5 high-quality images\n• First image will be the main display\n• Supported formats: JPG, PNG, WebP',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _pickImage,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isLoading ? Colors.grey.shade300 : Colors.deepPurple,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _isLoading ? Colors.grey.shade100 : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 40,
              color: _isLoading ? Colors.grey : Colors.deepPurple,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb 
              ? Image.memory(
                  _selectedImages[index] as Uint8List,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  _selectedImages[index] as File,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
          ),
          // Main image indicator
          if (index == 0)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Main',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Remove button
          if (!_isLoading)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImages.removeAt(index);
                    if (kIsWeb) {
                      _imageNames.removeAt(index);
                    }
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: _uploadProgress,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _uploadStatus,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${(_uploadProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Artwork Title *',
            border: OutlineInputBorder(),
            helperText: 'Give your artwork a descriptive title',
          ),
          maxLength: 100,
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter artwork title';
            }
            if (value.trim().length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            border: OutlineInputBorder(),
            helperText: 'Describe your artwork, inspiration, and techniques',
          ),
          maxLines: 4,
          maxLength: 1000,
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter description';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _selectedArtType,
          decoration: const InputDecoration(
            labelText: 'Art Type *',
            border: OutlineInputBorder(),
          ),
          items: _artTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _selectedArtType = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _selectedArtStyle,
          decoration: const InputDecoration(
            labelText: 'Art Style *',
            border: OutlineInputBorder(),
          ),
          items: _artStyles.map((style) {
            return DropdownMenuItem(value: style, child: Text(style));
          }).toList(),
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _selectedArtStyle = value!;
            });
          },
        ),
        const SizedBox(height: 16),

        // Medium field
        TextFormField(
          controller: _mediumController,
          decoration: const InputDecoration(
            labelText: 'Medium *',
            border: OutlineInputBorder(),
            helperText: 'e.g., Oil on canvas, Acrylic, Watercolor, Digital',
          ),
          maxLength: 100,
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the medium used';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Dimensions field
        TextFormField(
          controller: _dimensionsController,
          decoration: const InputDecoration(
            labelText: 'Dimensions',
            border: OutlineInputBorder(),
            helperText: 'e.g., 24 x 36 inches, 60 x 90 cm (optional)',
          ),
          maxLength: 50,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _priceController,
          decoration: const InputDecoration(
            labelText: 'Price (USD) *',
            border: OutlineInputBorder(),
            prefixText: '\$ ',
            helperText: 'Set a fair price for your artwork',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter price';
            }
            final price = double.tryParse(value.trim());
            if (price == null) {
              return 'Please enter valid price';
            }
            if (price < 1) {
              return 'Price must be at least \$1';
            }
            if (price > 100000) {
              return 'Price cannot exceed \$100,000';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        SwitchListTile(
          title: const Text('Available for Sale'),
          subtitle: const Text('Allow customers to purchase this artwork'),
          value: _isAvailable,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _isAvailable = value;
            });
          },
          activeColor: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildCreatePostButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Creating Post...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.publish),
                  const SizedBox(width: 8),
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (kIsWeb) {
        // Web-specific image picking using conditional import
        await _pickImageWeb();
      } else {
        // Mobile/Desktop image picking using image_picker
        await _pickImageMobile();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: Please try again'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageWeb() async {
    // This method will only be called on web platforms
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files!.isEmpty) return;

      final file = files[0];
      
      // Check file size (max 10MB)
      if (file.size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size must be less than 10MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check file type
      if (!file.type.startsWith('image/')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid image file'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        final bytes = reader.result as List<int>;
        setState(() {
          _selectedImages.add(Uint8List.fromList(bytes));
          _imageNames.add(file.name);
        });
      });
    });
  }

  Future<void> _pickImageMobile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      
      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size must be less than 10MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _selectedImages.add(imageFile);
      });
    }
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Preparing to upload...';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      
      final currentUser = authService.currentUser;
      final currentUserModel = authService.currentUserModel;
      
      if (currentUser == null || currentUserModel == null) {
        throw Exception('User not authenticated');
      }

      // Update status
      setState(() {
        _uploadStatus = 'Uploading images to Cloudinary...';
      });

      // Upload images to Cloudinary with progress tracking
      final List<String> imageUrls = [];
      
      for (int i = 0; i < _selectedImages.length; i++) {
        setState(() {
          _uploadProgress = (i / _selectedImages.length) * 0.8; // 80% for uploads
          _uploadStatus = 'Uploading image ${i + 1} of ${_selectedImages.length}...';
        });

        CloudinaryResponse response;
        
        if (kIsWeb) {
          // For web, use bytes upload
          response = await CloudinaryService.uploadArtworkImageFromBytes(
            imageBytes: _selectedImages[i] as Uint8List,
            fileName: _imageNames[i],
            artistId: currentUser.uid,
          );
        } else {
          // For mobile/desktop, use file upload
          response = await CloudinaryService.uploadArtworkImage(
            imageFile: _selectedImages[i] as File,
            artistId: currentUser.uid,
          );
        }

        if (response.success && response.secureUrl != null) {
          imageUrls.add(response.secureUrl!);
          print('✅ Image ${i + 1} uploaded: ${response.secureUrl}');
        } else {
          throw Exception('Failed to upload image ${i + 1}: ${response.error}');
        }
      }

      // Update progress
      setState(() {
        _uploadProgress = 0.9;
        _uploadStatus = 'Saving artwork to database...';
      });

      // Create artwork model with ALL required parameters
      final artwork = ArtworkModel(
        id: '', // Firestore will generate this
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: imageUrls, // Cloudinary URLs
        price: double.parse(_priceController.text.trim()),
        artStyle: _selectedArtStyle,
        artType: _selectedArtType,
        medium: _mediumController.text.trim(), // Required parameter
        dimensions: _dimensionsController.text.trim(), // Required parameter (can be empty)
        availability: _isAvailable,
        artistId: currentUser.uid, // Linked to user's UID for retrieval
        artistName: currentUserModel.name, // Use the user's name
        createdAt: Timestamp.now(), // Use Firestore Timestamp
      );

      // Save to Firestore
      await firestoreService.createArtwork(artwork);

      // Final progress
      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = 'Artwork posted successfully!';
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Artwork posted successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to artist home
      await Future.delayed(const Duration(milliseconds: 500));
      context.go('/artist/home');

    } catch (e) {
      print('❌ Error creating post: $e');
      
      setState(() {
        _uploadStatus = 'Error: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}