/// Profile Header Widget
///
/// A beautiful header widget for the user profile screen
/// with Hindu traditional design elements
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import '../../../../core/design_system/design_system.dart';
import '../../../../core/models/user/user_model.dart';
import '../../../../core/services/user/profile_photo_service.dart';
import '../../../../core/services/user/profile_photo_provider.dart';
import '../../../../shared/widgets/common/centralized_widgets.dart';

class ProfileHeaderWidget extends ConsumerStatefulWidget {
  final UserModel? user;
  final Function(String?)? onProfilePictureChanged;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    this.onProfilePictureChanged,
  });

  @override
  ConsumerState<ProfileHeaderWidget> createState() =>
      _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends ConsumerState<ProfileHeaderWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profilePhotoNotifierProvider.notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    // ResponsiveSystem.init(context); // Removed - not needed
    final profilePhotoAsync = ref.watch(profilePhotoNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: ThemeProperties.getPrimaryGradient(context),
      ),
      padding:
          EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 24)),
      child: Column(
        children: [
          // Profile Photo Picker Section
          GestureDetector(
            onTap: () => _showImagePicker(context),
            child: Container(
              width: ResponsiveSystem.spacing(context, baseSpacing: 120),
              height: ResponsiveSystem.spacing(context, baseSpacing: 120),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeProperties.getSurfaceColor(context),
                  width: ResponsiveSystem.borderWidth(context, baseWidth: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeProperties.getShadowColor(context),
                    blurRadius:
                        ResponsiveSystem.spacing(context, baseSpacing: 12),
                    offset: Offset(
                        0, ResponsiveSystem.spacing(context, baseSpacing: 6)),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: ResponsiveSystem.spacing(context, baseSpacing: 58),
                    backgroundColor: ThemeProperties.getSurfaceColor(context),
                    backgroundImage: profilePhotoAsync.hasValue &&
                            profilePhotoAsync.value != null
                        ? (profilePhotoAsync.value!.startsWith('data:')
                            ? null // For web data URLs, we'll handle in child
                            : FileImage(File(profilePhotoAsync.value!)))
                        : null,
                    child: profilePhotoAsync.hasValue &&
                            profilePhotoAsync.value != null
                        ? (profilePhotoAsync.value!.startsWith('data:')
                            ? _buildWebImage(profilePhotoAsync.value!)
                            : null)
                        : _buildDefaultAvatar(context),
                  ),
                  // Camera icon overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: ResponsiveSystem.spacing(context, baseSpacing: 32),
                      height:
                          ResponsiveSystem.spacing(context, baseSpacing: 32),
                      decoration: BoxDecoration(
                        color: ThemeProperties.getPrimaryColor(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemeProperties.getSurfaceColor(context),
                          width: ResponsiveSystem.borderWidth(context,
                              baseWidth: 3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeProperties.getShadowColor(context),
                            blurRadius: ResponsiveSystem.spacing(context,
                                baseSpacing: 8),
                            offset: Offset(
                                0,
                                ResponsiveSystem.spacing(context,
                                    baseSpacing: 4)),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: ThemeProperties.getSurfaceColor(context),
                        size: ResponsiveSystem.iconSize(context, baseSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 20)),

          // Photo Picker Text
          Text(
            profilePhotoAsync.hasValue && profilePhotoAsync.value != null
                ? 'Tap to change photo'
                : 'Tap to add your photo',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeProperties.getPrimaryTextColor(context)
                  .withAlpha((0.8 * 255).round()),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

          // Quick Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickStat(
                context,
                'Gender',
                widget.user?.sex ?? 'N/A',
                Icons.face,
              ),
              _buildQuickStat(
                context,
                'Birth Place',
                widget.user?.placeOfBirth.split(',').first ?? 'N/A',
                Icons.location_on,
              ),
              _buildQuickStat(
                context,
                'Age',
                _calculateAge(widget.user?.dateOfBirth).toString(),
                Icons.cake,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeProperties.getTransparentColor(context),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ThemeProperties.getSurfaceColor(context),
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                  ResponsiveSystem.borderRadius(context, baseRadius: 20))),
          boxShadow:
              ThemeProperties.getElevatedShadows(context, elevation: 2.0),
        ),
        padding:
            EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ResponsiveSystem.spacing(context, baseSpacing: 40),
              height: ResponsiveSystem.spacing(context, baseSpacing: 4),
              decoration: BoxDecoration(
                color: ThemeProperties.getDividerColor(context),
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 2),
              ),
            ),
            SizedBox(
                height: ResponsiveSystem.spacing(context, baseSpacing: 20)),
            Text(
              'Select Profile Picture',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ThemeProperties.getPrimaryTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(
                height: ResponsiveSystem.spacing(context, baseSpacing: 20)),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: ResponsiveSystem.spacing(context, baseSpacing: 12),
              runSpacing: ResponsiveSystem.spacing(context, baseSpacing: 12),
              children: [
                if (!kIsWeb) ...[
                  _buildImagePickerOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _pickImage(context, ImageSource.camera),
                  ),
                  _buildImagePickerOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickImage(context, ImageSource.gallery),
                  ),
                ] else ...[
                  _buildImagePickerOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Choose File',
                    onTap: () => _pickImage(context, ImageSource.gallery),
                  ),
                ],
                _buildImagePickerOption(
                  context,
                  icon: Icons.delete,
                  label: 'Remove',
                  onTap: () => _removeImage(context),
                ),
              ],
            ),
            SizedBox(
                height: ResponsiveSystem.spacing(context, baseSpacing: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return CentralizedModernButton(
      text: label,
      onPressed: () {
        Navigator.pop(context);
        onTap();
      },
      padding:
          EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 12)),
      backgroundColor: ThemeProperties.getSurfaceContainerColor(context),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      // Check if running on web
      if (kIsWeb) {
        await _showWebImagePicker(context);
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        // Save image to app directory
        final String? savedPath =
            await ProfilePhotoService.saveImageToAppDirectory(image.path);
        if (savedPath != null) {
          // Save path to SharedPreferences
          await ProfilePhotoService.saveProfilePhotoPath(savedPath);
          // Update the global provider state
          ref
              .read(profilePhotoNotifierProvider.notifier)
              .updatePhotoPath(savedPath);
          widget.onProfilePictureChanged?.call(savedPath);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: ThemeProperties.getErrorColor(context),
          ),
        );
      }
    }
  }

  Future<void> _showWebImagePicker(BuildContext context) async {
    try {
      if (kIsWeb) {
        await _pickImageFromWeb();
      } else {
        // For mobile apps, use ImagePicker as fallback
        await _pickImage(context, ImageSource.gallery);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: ThemeProperties.getErrorColor(context),
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromWeb() async {
    try {
      // Create a file input element
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      // Listen for file selection
      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();

          reader.onLoadEnd.listen((e) async {
            final result = reader.result;
            if (result != null) {
              // Convert to data URL
              final dataUrl = result.toString();
              // Save to SharedPreferences for persistence
              await ProfilePhotoService.saveProfilePhotoPath(dataUrl);
              // Update the provider state
              ref
                  .read(profilePhotoNotifierProvider.notifier)
                  .updatePhotoPath(dataUrl);
              widget.onProfilePictureChanged?.call(dataUrl);
            }
          });

          reader.readAsDataUrl(file);
        }
      });
    } catch (e) {
      // Swallow errors silently in web file picker; log if needed
    }
  }

  void _removeImage(BuildContext context) async {
    await ProfilePhotoService.removeProfilePhoto();
    // Update the provider state
    ref.read(profilePhotoNotifierProvider.notifier).clearPhoto();
    widget.onProfilePictureChanged?.call(null);
  }

  Widget _buildWebImage(String dataUrl) {
    return ClipOval(
      child: Image.network(
        dataUrl,
        width: ResponsiveSystem.spacing(context, baseSpacing: 116), // 58 * 2
        height: ResponsiveSystem.spacing(context, baseSpacing: 116),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar(context);
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: ResponsiveSystem.spacing(context,
          baseSpacing: 23), // Match the circle avatar radius
      height: ResponsiveSystem.spacing(context, baseSpacing: 23),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: ThemeProperties.getPrimaryGradient(context),
      ),
      child: Icon(
        Icons.face,
        size: ResponsiveSystem.iconSize(context,
            baseSize: 60), // Increased icon size
        color: ThemeProperties.getSurfaceColor(context),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(
              ResponsiveSystem.spacing(context, baseSpacing: 12)),
          decoration: BoxDecoration(
            color: ThemeProperties.getSurfaceColor(context)
                .withAlpha((0.2 * 255).round()),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
          ),
          child: Icon(
            icon,
            color: ThemeProperties.getSurfaceColor(context),
            size: ResponsiveSystem.iconSize(context, baseSize: 24),
          ),
        ),
        SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            color: ThemeProperties.getSurfaceColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
            color: ThemeProperties.getPrimaryTextColor(context)
                .withAlpha((0.8 * 255).round()),
          ),
        ),
      ],
    );
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
