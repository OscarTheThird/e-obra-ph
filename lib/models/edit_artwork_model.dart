import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/artwork_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditArtworkScreen extends StatefulWidget {
  final String artworkId;
  
  const EditArtworkScreen({super.key, required this.artworkId});

  @override
  State<EditArtworkScreen> createState() => _EditArtworkScreenState();
}

class _EditArtworkScreenState extends State<EditArtworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _mediumController = TextEditingController();
  final _dimensionsController = TextEditingController();
  
  String _selectedArtStyle = 'Abstract';
  bool _availability = true;
  bool _isLoading = false;
  bool _isLoadingArtwork = true;
  
  List<String> _existingImages = [];
  List<dynamic> _newImages = []; // Can be File or Uint8List
  final ImagePicker _picker = ImagePicker();
  
  ArtworkModel? _originalArtwork;

  final List<String> _artStyles = [
    'Abstract',
    'Realism',
    'Impressionism',
    'Expressionism',
    'Surrealism',
    'Pop Art',
    'Minimalism',
    'Contemporary',
    'Traditional',
    'Digital Art',
    'Mixed Media',
    'Photography',
    'Sculpture',
    'Backdrop painting',
    'Modern',
    'Other'
  ].toSet().toList();

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _mediumController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  Future<void> _loadArtwork() async {
    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final artwork = await firestoreService.getArtwork(widget.artworkId);
      
      if (artwork != null) {
        setState(() {
          _originalArtwork = artwork;
          _titleController.text = artwork.title;
          _descriptionController.text = artwork.description;
          _priceController.text = artwork.price.toString();
          _mediumController.text = artwork.medium;
          _dimensionsController.text = artwork.dimensions;
          _selectedArtStyle = artwork.artStyle;
          _availability = artwork.availability;
          _existingImages = List.from(artwork.images);
          _isLoadingArtwork = false;
        });
      } else {
        _showErrorAndGoBack('Artwork not found');
      }
    } catch (e) {
      _showErrorAndGoBack('Error loading artwork: $e');
    }
  }

  void _showErrorAndGoBack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    context.go('/artist/profile');
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _newImages.add(bytes);
          });
        } else {
          final file = File(image.path);
          setState(() {
            _newImages.add(file);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultipleMedia(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        for (final image in images) {
          if (image.mimeType?.startsWith('image/') == true) {
            if (kIsWeb) {
              final bytes = await image.readAsBytes();
              setState(() {
                _newImages.add(bytes);
              });
            } else {
              final file = File(image.path);
              setState(() {
                _newImages.add(file);
              });
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Widget _buildImageGrid() {
    final totalImages = _existingImages.length + _newImages.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            // Wrap buttons in a flexible container to prevent overflow
            Flexible(
              child: Wrap(
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate, size: 18),
                    label: const Text('Add', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickMultipleImages,
                    icon: const Icon(Icons.add_photo_alternate, size: 18),
                    label: const Text('Multiple', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (totalImages == 0)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('No images selected'),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: totalImages,
            itemBuilder: (context, index) {
              if (index < _existingImages.length) {
                return _buildExistingImageTile(index);
              } else {
                return _buildNewImageTile(index - _existingImages.length);
              }
            },
          ),
      ],
    );
  }

  Widget _buildExistingImageTile(int index) {
    final imageUrl = _existingImages[index];
    final publicId = CloudinaryUtils.extractPublicId(imageUrl);
    final thumbnailUrl = publicId != null 
        ? CloudinaryService.getThumbnailUrl(publicId, size: 200)
        : imageUrl;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeExistingImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImageTile(int index) {
    final imageFile = _newImages[index];
    
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: kIsWeb
                ? Image.memory(
                    imageFile as Uint8List,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    imageFile as File,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeNewImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateArtwork() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final user = authService.currentUserModel;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      List<String> allImageUrls = List.from(_existingImages);

      // Upload new images
      for (final imageFile in _newImages) {
        CloudinaryResponse response;
        
        if (kIsWeb && imageFile is Uint8List) {
          response = await CloudinaryService.uploadArtworkImageFromBytes(
            imageBytes: imageFile,
            fileName: 'artwork_${DateTime.now().millisecondsSinceEpoch}.jpg',
            artistId: user.uid,
            artworkId: widget.artworkId,
          );
        } else {
          response = await CloudinaryService.uploadArtworkImage(
            imageFile: imageFile,
            artistId: user.uid,
            artworkId: widget.artworkId,
          );
        }

        if (response.success && response.secureUrl != null) {
          allImageUrls.add(response.secureUrl!);
        } else {
          throw Exception('Failed to upload image: ${response.error}');
        }
      }

      // Create updated artwork model
      final updatedArtwork = ArtworkModel(
        id: widget.artworkId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        medium: _mediumController.text.trim(),
        dimensions: _dimensionsController.text.trim(),
        artStyle: _selectedArtStyle,
        artType: _originalArtwork!.artType,
        availability: _availability,
        images: allImageUrls,
        artistId: user.uid,
        artistName: user.name,
        createdAt: _originalArtwork!.createdAt,
      );

      // Update in Firestore
      await firestoreService.updateArtwork(widget.artworkId, updatedArtwork);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artwork updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/artist/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update artwork: $e'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoadingArtwork) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('Edit Artwork', style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/artist/profile'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Artwork Details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price and Art Style Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Price (\$) *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a price';
                                }
                                if (double.tryParse(value.trim()) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedArtStyle,
                              decoration: InputDecoration(
                                labelText: 'Art Style *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.palette),
                              ),
                              items: _artStyles.map((style) {
                                return DropdownMenuItem(value: style, child: Text(style));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedArtStyle = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Medium and Dimensions Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _mediumController,
                              decoration: InputDecoration(
                                labelText: 'Medium',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.brush),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _dimensionsController,
                              decoration: InputDecoration(
                                labelText: 'Dimensions',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.straighten),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Availability Toggle
                      SwitchListTile(
                        title: const Text('Available for Sale'),
                        subtitle: Text(_availability ? 'This artwork is available for purchase' : 'This artwork is not available for sale'),
                        value: _availability,
                        onChanged: (value) {
                          setState(() {
                            _availability = value;
                          });
                        },
                        activeColor: Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // Images Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildImageGrid(),
                ),
              ),

              const SizedBox(height: 30),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateArtwork,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Updating...'),
                          ],
                        )
                      : const Text('Update Artwork'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}