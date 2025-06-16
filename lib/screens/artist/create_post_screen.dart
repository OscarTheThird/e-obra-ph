// screens/artist/create_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/artwork_model.dart';
import '../../utils/image_picker_service_factory.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _mediumController = TextEditingController();
  final _dimensionsController = TextEditingController();
  
  String _selectedArtType = 'Painting';
  String _selectedArtStyle = 'Abstract';
  bool _isAvailable = true;
  List<dynamic> _selectedImages = [];
  List<String> _imageNames = [];
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Custom Color Palette
  static const Color primaryOrange = Color(0xFFE8541D);
  static const Color primaryGreen = Color(0xFF00BF63);
  static const Color primaryPurple = Color(0xFF5E17EB);
  static const Color backgroundWhite = Colors.white;
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFFE9ECEF);
  static const Color darkGray = Color(0xFF6C757D);

  final List<String> _artTypes = [
    'Painting',
    'Backdrop painting',
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
    'Backdrop painting',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      backgroundColor: lightGray,
      appBar: _buildModernAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(),
              
              // Main Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Image Upload Card
                      _buildImageUploadCard(),
                      const SizedBox(height: 24),
                      
                      // Loading Progress
                      if (_isLoading) _buildModernUploadProgress(),
                      
                      // Form Fields Card
                      _buildFormFieldsCard(),
                      
                      const SizedBox(height: 32),
                      
                      // Create Post Button
                      _buildModernCreatePostButton(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundWhite,
      surfaceTintColor: Colors.transparent,
      leading: _isLoading 
          ? null 
          : IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.close, size: 20),
              ),
              onPressed: () => context.go('/artist/home'),
            ),
      title: const Text(
        'Create Artwork',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        if (!_isLoading)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.help_outline, color: primaryPurple),
              ),
              onPressed: () {
                _showHelpDialog();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryPurple.withOpacity(0.1),
            primaryOrange.withOpacity(0.05),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.palette,
              size: 48,
              color: primaryOrange,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Share Your Creative Vision',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your artwork and connect with art enthusiasts',
            style: TextStyle(
              fontSize: 14,
              color: darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image, color: primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Artwork Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedImages.length >= 5 
                      ? primaryOrange.withOpacity(0.1) 
                      : mediumGray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedImages.length}/5',
                  style: TextStyle(
                    color: _selectedImages.length >= 5 ? primaryOrange : darkGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Image Grid
          if (_selectedImages.isEmpty)
            _buildEmptyImageState()
          else
            _buildImageGrid(),
          
          const SizedBox(height: 16),
          
          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates, color: primaryPurple, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photo Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryPurple,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Use high-quality, well-lit photos\n• First image becomes the main display\n• Supported: JPG, PNG, WebP',
                        style: TextStyle(
                          fontSize: 11,
                          color: darkGray,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyImageState() {
    return GestureDetector(
      onTap: _isLoading ? null : _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isLoading ? mediumGray : primaryGreen,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: _isLoading ? lightGray : primaryGreen.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate,
                size: 48,
                color: _isLoading ? darkGray : primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Your First Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isLoading ? darkGray : primaryGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to select from gallery',
              style: TextStyle(
                fontSize: 12,
                color: darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _selectedImages.length + (_selectedImages.length < 5 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _selectedImages.length) {
              return _buildAddMoreButton();
            }
            return _buildModernImagePreview(index);
          },
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _pickImage,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _isLoading ? mediumGray : primaryGreen,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: _isLoading ? lightGray : primaryGreen.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 32,
              color: _isLoading ? darkGray : primaryGreen,
            ),
            const SizedBox(height: 4),
            Text(
              'Add More',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _isLoading ? darkGray : primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernImagePreview(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: kIsWeb 
              ? Image.memory(
                  _selectedImages[index] as Uint8List,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  _selectedImages[index] as File,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
          ),
          
          // Main image indicator
          if (index == 0)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImages.removeAt(index);
                    if (kIsWeb && _imageNames.length > index) {
                      _imageNames.removeAt(index);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernUploadProgress() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: _uploadProgress,
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
                    backgroundColor: mediumGray,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _uploadStatus,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please wait while we process your artwork...',
                      style: TextStyle(
                        fontSize: 12,
                        color: darkGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(_uploadProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: mediumGray,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _uploadProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPurple, primaryOrange],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit, color: primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Artwork Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildModernTextField(
            controller: _titleController,
            label: 'Artwork Title',
            hint: 'Give your artwork a descriptive title',
            icon: Icons.title,
            maxLength: 100,
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
          
          const SizedBox(height: 20),
          
          _buildModernTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Describe your artwork, inspiration, and techniques',
            icon: Icons.description,
            maxLines: 4,
            maxLength: 1000,
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
          
          const SizedBox(height: 20),
          
          // Use column layout for smaller screens to prevent overflow
          _buildModernDropdown(
            value: _selectedArtType,
            items: _artTypes,
            label: 'Art Type',
            icon: Icons.category,
            onChanged: (value) {
              setState(() {
                _selectedArtType = value!;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildModernDropdown(
            value: _selectedArtStyle,
            items: _artStyles,
            label: 'Art Style',
            icon: Icons.style,
            onChanged: (value) {
              setState(() {
                _selectedArtStyle = value!;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildModernTextField(
            controller: _mediumController,
            label: 'Medium',
            hint: 'e.g., Oil on canvas, Acrylic',
            icon: Icons.brush,
            maxLength: 100,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the medium used';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildModernTextField(
            controller: _dimensionsController,
            label: 'Dimensions',
            hint: 'e.g., 24 x 36 inches',
            icon: Icons.straighten,
            maxLength: 50,
          ),
          
          const SizedBox(height: 20),
          
          _buildModernTextField(
            controller: _priceController,
            label: 'Price (PHP)',
            hint: 'Set a fair price for your artwork',
            icon: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixText: '₱ ',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter price';
              }
              final price = double.tryParse(value.trim());
              if (price == null) {
                return 'Please enter valid price';
              }
              if (price < 50) {
                return 'Price must be at least ₱50';
              }
              if (price > 5000000) {
                return 'Price cannot exceed ₱5,000,000';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          _buildModernSwitch(),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      enabled: !_isLoading,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryPurple, size: 18),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: lightGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: _isLoading ? null : onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryGreen, size: 18),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: lightGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildModernSwitch() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryGreen.withOpacity(0.1),
            primaryGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.store, color: primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available for Sale',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Allow customers to purchase this artwork',
                  style: TextStyle(
                    fontSize: 12,
                    color: darkGray,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: _isLoading ? null : (value) {
              setState(() {
                _isAvailable = value;
              });
            },
            activeColor: primaryGreen,
            activeTrackColor: primaryGreen.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCreatePostButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _isLoading 
            ? LinearGradient(colors: [Colors.grey, Colors.grey])
            : LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [primaryOrange, primaryPurple],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLoading ? [] : [
          BoxShadow(
            color: primaryOrange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    'Creating Post...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.publish,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Create Artwork Post',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) {
      _showCustomSnackBar(
        'Maximum 5 images allowed',
        primaryOrange,
        Icons.warning,
      );
      return;
    }

    try {
      final imagePickerService = createImagePickerService();
      final pickedImages = await imagePickerService.pickImages(maxImages: 1);
      
      if (pickedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedImages);
          if (kIsWeb) {
            _imageNames.addAll(List.generate(pickedImages.length, (index) => 'image_${DateTime.now().millisecondsSinceEpoch}_$index.jpg'));
          }
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showCustomSnackBar(
        'Error picking image: $e',
        Colors.red,
        Icons.error,
      );
    }
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedImages.isEmpty) {
      _showCustomSnackBar(
        'Please add at least one image',
        primaryOrange,
        Icons.warning,
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

      setState(() {
        _uploadStatus = 'Uploading images to Cloudinary...';
      });

      final List<String> imageUrls = [];
      
      for (int i = 0; i < _selectedImages.length; i++) {
        setState(() {
          _uploadProgress = (i / _selectedImages.length) * 0.8;
          _uploadStatus = 'Uploading image ${i + 1} of ${_selectedImages.length}...';
        });

        CloudinaryResponse response;
        
        if (kIsWeb) {
          response = await CloudinaryService.uploadArtworkImageFromBytes(
            imageBytes: _selectedImages[i] as Uint8List,
            fileName: _imageNames[i],
            artistId: currentUser.uid,
          );
        } else {
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

      setState(() {
        _uploadProgress = 0.9;
        _uploadStatus = 'Saving artwork to database...';
      });

      final artwork = ArtworkModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: imageUrls,
        price: double.parse(_priceController.text.trim()),
        artStyle: _selectedArtStyle,
        artType: _selectedArtType,
        medium: _mediumController.text.trim(),
        dimensions: _dimensionsController.text.trim(),
        availability: _isAvailable,
        artistId: currentUser.uid,
        artistName: currentUserModel.name,
        createdAt: Timestamp.now(),
      );

      await firestoreService.createArtwork(artwork);

      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = 'Artwork posted successfully!';
      });

      _showCustomSnackBar(
        'Artwork posted successfully!',
        primaryGreen,
        Icons.check_circle,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      context.go('/artist/home');

    } catch (e) {
      print('❌ Error creating post: $e');
      
      setState(() {
        _uploadStatus = 'Error: $e';
      });

      _showCustomSnackBar(
        'Error: ${e.toString()}',
        Colors.red,
        Icons.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.help, color: primaryPurple, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Create Post Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpTip(
                  '📸 Photos',
                  'Use high-quality, well-lit images. The first photo will be your main display image.',
                ),
                const SizedBox(height: 12),
                _buildHelpTip(
                  '✏️ Title & Description',
                  'Write a compelling title and detailed description including your inspiration and techniques.',
                ),
                const SizedBox(height: 12),
                _buildHelpTip(
                  '🎨 Categories',
                  'Choose accurate art type and style to help buyers find your work.',
                ),
                const SizedBox(height: 12),
                _buildHelpTip(
                  '💰 Pricing',
                  'Research similar artworks and price competitively. Consider materials, time, and skill level.',
                ),
              ],
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, primaryGreen],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpTip(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: darkGray,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}