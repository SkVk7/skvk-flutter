/// User Profile Form Widget
///
/// Reusable form widget following Flutter design principles
/// Implements proper separation of concerns and validation
library;

import '../../../../core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_model.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';
import '../../../../astrology/core/constants/astrology_constants.dart';
import '../../../../shared/widgets/centralized_widgets.dart';
import '../../../../shared/widgets/enhanced_dropdown_widgets.dart';
import '../../../../shared/widgets/dropdown_info_adapters.dart';

import '../../../../core/theme/theme_provider.dart';

/// Form field types for validation
enum UserProfileFieldType {
  name,
  placeOfBirth,
  dateOfBirth,
  timeOfBirth,
  coordinates,
  ayanamsha,
}

/// Form validation result
class FormValidationResult {
  final bool isValid;
  final Map<UserProfileFieldType, String> errors;

  const FormValidationResult({
    required this.isValid,
    required this.errors,
  });

  String? getError(UserProfileFieldType field) => errors[field];
}

/// User profile form data model
class UserProfileFormData {
  final String name;
  final DateTime dateOfBirth;
  final TimeOfDay timeOfBirth;
  final String placeOfBirth;
  final double latitude;
  final double longitude;
  final AyanamshaType ayanamsha;

  const UserProfileFormData({
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.latitude,
    required this.longitude,
    required this.ayanamsha,
  });

  UserProfileFormData copyWith({
    String? name,
    DateTime? dateOfBirth,
    TimeOfDay? timeOfBirth,
    String? placeOfBirth,
    double? latitude,
    double? longitude,
    AyanamshaType? ayanamsha,
  }) {
    return UserProfileFormData(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ayanamsha: ayanamsha ?? this.ayanamsha,
    );
  }

  /// Validate form data
  FormValidationResult validate() {
    final errors = <UserProfileFieldType, String>{};

    // Name validation
    if (name.trim().isEmpty) {
      errors[UserProfileFieldType.name] = 'Name is required';
    } else if (name.trim().length < 2) {
      errors[UserProfileFieldType.name] = 'Name must be at least 2 characters';
    } else if (name.trim().length > 50) {
      errors[UserProfileFieldType.name] = 'Name must be less than 50 characters';
    }

    // Place of birth validation
    if (placeOfBirth.trim().isEmpty) {
      errors[UserProfileFieldType.placeOfBirth] = 'Place of birth is required';
    }

    // Date of birth validation
    if (dateOfBirth.isAfter(DateTime.now())) {
      errors[UserProfileFieldType.dateOfBirth] = 'Date of birth cannot be in the future';
    } else if (dateOfBirth.isBefore(DateTime(1900))) {
      errors[UserProfileFieldType.dateOfBirth] = 'Date of birth cannot be before 1900';
    }

    // Coordinates validation
    if (latitude == 0.0 && longitude == 0.0) {
      errors[UserProfileFieldType.coordinates] = 'Please select a valid place of birth';
    } else if (latitude < -90 || latitude > 90) {
      errors[UserProfileFieldType.coordinates] = 'Invalid latitude';
    } else if (longitude < -180 || longitude > 180) {
      errors[UserProfileFieldType.coordinates] = 'Invalid longitude';
    }

    return FormValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Convert to UserModel
  UserModel toUserModel() {
    return UserModel.create(
      name: name.trim(),
      dateOfBirth: dateOfBirth,
      timeOfBirth: TimeOfBirth.fromTimeOfDay(timeOfBirth),
      placeOfBirth: placeOfBirth.trim(),
      latitude: latitude,
      longitude: longitude,
      ayanamsha: ayanamsha,
      sex: 'Male', // Default value, will be updated by user selection
    );
  }
}

/// User Profile Form Widget
class UserProfileForm extends ConsumerStatefulWidget {
  final UserProfileFormData initialData;
  final bool isEditing;
  final Function(UserProfileFormData) onDataChanged;
  final Function(UserProfileFormData) onSave;
  final VoidCallback onCancel;
  final bool isLoading;

  const UserProfileForm({
    super.key,
    required this.initialData,
    required this.isEditing,
    required this.onDataChanged,
    required this.onSave,
    required this.onCancel,
    required this.isLoading,
  });

  @override
  ConsumerState<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends ConsumerState<UserProfileForm> {
  late UserProfileFormData _formData;
  final Map<UserProfileFieldType, String> _fieldErrors = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeOfBirthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formData = widget.initialData;
    _initializeControllers();
  }

  @override
  void didUpdateWidget(UserProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialData != widget.initialData) {
      _formData = widget.initialData;
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _nameController.text = _formData.name;
    _placeOfBirthController.text = _formData.placeOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeOfBirthController.dispose();
    super.dispose();
  }

  void _updateFormData(UserProfileFormData newData) {
    setState(() {
      _formData = newData;
      _fieldErrors.clear();
    });
    widget.onDataChanged(newData);
  }

  void _validateAndSave() {
    final validation = _formData.validate();
    setState(() {
      _fieldErrors.clear();
      _fieldErrors.addAll(validation.errors);
    });

    if (validation.isValid) {
      widget.onSave(_formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Name Field
        _buildNameField(),
        SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

        // Date of Birth Field
        _buildDateOfBirthField(),
        SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

        // Time of Birth Field
        _buildTimeOfBirthField(),
        SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

        // Place of Birth Field
        _buildPlaceOfBirthField(),
        SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

        // Ayanamsha Field
        _buildAyanamshaField(),
        SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 24)),

        // Action Buttons
        if (widget.isEditing) _buildActionButtons(),
      ],
    );
  }

  Widget _buildNameField() {
    return _FormFieldWrapper(
      label: 'Name',
      error: _fieldErrors[UserProfileFieldType.name],
      child: TextField(
        controller: _nameController,
        enabled: widget.isEditing,
        onChanged: (value) => _updateFormData(_formData.copyWith(name: value)),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.face),
          hintText: 'Enter your full name',
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return _FormFieldWrapper(
      label: 'Date of Birth',
      error: _fieldErrors[UserProfileFieldType.dateOfBirth],
      child: CentralizedDatePicker(
        selectedDate: _formData.dateOfBirth,
        onDateChanged: widget.isEditing
            ? (date) => _updateFormData(_formData.copyWith(dateOfBirth: date))
            : (date) {},
      ),
    );
  }

  Widget _buildTimeOfBirthField() {
    return _FormFieldWrapper(
      label: 'Time of Birth',
      error: _fieldErrors[UserProfileFieldType.timeOfBirth],
      child: CentralizedTimePicker(
        selectedTime: _formData.timeOfBirth,
        onTimeChanged: widget.isEditing
            ? (time) => _updateFormData(_formData.copyWith(timeOfBirth: time))
            : (time) {},
      ),
    );
  }

  Widget _buildPlaceOfBirthField() {
    return _FormFieldWrapper(
      label: 'Place of Birth',
      error: _fieldErrors[UserProfileFieldType.placeOfBirth],
      child: TextField(
        controller: _placeOfBirthController,
        enabled: widget.isEditing,
        onChanged: (value) => _updateFormData(_formData.copyWith(placeOfBirth: value)),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.location_on),
          hintText: 'Enter place of birth',
          suffixIcon: widget.isEditing
              ? IconButton(
                  icon: Icon(Icons.my_location),
                  onPressed: _selectCoordinates,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildAyanamshaField() {
    return _FormFieldWrapper(
      label: 'Ayanamsha System',
      error: _fieldErrors[UserProfileFieldType.ayanamsha],
      child: _AyanamshaSelector(
        selectedAyanamsha: _formData.ayanamsha,
        onTap: widget.isEditing ? _showAyanamshaSelector : null,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CentralizedModernButton(
          text: 'Save Profile',
          onPressed: widget.isLoading ? null : _validateAndSave,
          isLoading: widget.isLoading,
          width: ResponsiveSystem.screenWidth(context),
        ),
        ResponsiveSystem.sizedBox(context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
        CentralizedModernButton(
          text: 'Cancel',
          onPressed: widget.isLoading ? null : widget.onCancel,
          backgroundColor: ThemeProperties.getTransparentColor(context),
          textColor: ThemeProperties.getSecondaryTextColor(context),
          width: ResponsiveSystem.screenWidth(context),
        ),
      ],
    );
  }

  void _selectCoordinates() {
    // Implementation for coordinate selection
    // This would typically open a location picker or coordinate input dialog
  }

  void _showAyanamshaSelector() {
    showDialog(
      context: context,
      builder: (context) => _AyanamshaSelectionDialog(
        selectedAyanamsha: _formData.ayanamsha,
        onAyanamshaSelected: (ayanamsha) {
          _updateFormData(_formData.copyWith(ayanamsha: ayanamsha));
        },
      ),
    );
  }
}

/// Form field wrapper with consistent styling and error handling
class _FormFieldWrapper extends ConsumerWidget {
  final String label;
  final String? error;
  final Widget child;

  const _FormFieldWrapper({
    required this.label,
    required this.child,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  ThemeProperties.getSurfaceContainerColor(context),
                  ThemeProperties.getSurfaceContainerHighColor(context),
                  ThemeProperties.getSurfaceContainerColor(context),
                ]
              : [
                  ThemeProperties.getSurfaceColor(context),
                  ThemeProperties.getSurfaceContainerColor(context),
                  ThemeProperties.getSurfaceColor(context),
                ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 16)),
        boxShadow: [
          BoxShadow(
            color: ThemeProperties.getShadowColor(context).withAlpha(76),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 16),
            offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 8)),
          ),
          BoxShadow(
            color: ThemeProperties.getShadowColor(context).withAlpha(38),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
            offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                fontWeight: FontWeight.w600,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
            if (error != null) ...[
              SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
              Text(
                error!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  color: ThemeProperties.getErrorColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            child,
          ],
        ),
      ),
    );
  }
}

/// Ayanamsha selector widget
class _AyanamshaSelector extends ConsumerWidget {
  final AyanamshaType selectedAyanamsha;
  final VoidCallback? onTap;

  const _AyanamshaSelector({
    required this.selectedAyanamsha,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(primaryColorProvider);
    final primaryTextColor = ref.watch(primaryTextColorProvider);
    final secondaryTextColor = ref.watch(secondaryTextColorProvider);
    final borderColor = ref.watch(themePropertiesProvider)['borderColor'] as Color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveSystem.spacing(context, baseSpacing: 8)),
      child: Container(
        padding: EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 12)),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(ResponsiveSystem.spacing(context, baseSpacing: 8)),
        ),
        child: Row(
          children: [
            Icon(Icons.star,
                color: primaryColor, size: ResponsiveSystem.spacing(context, baseSpacing: 20)),
            SizedBox(width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AyanamshaConstants.displayNames[selectedAyanamsha] ?? selectedAyanamsha.name,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  if (AyanamshaConstants.regionalInfo[selectedAyanamsha] != null)
                    Padding(
                      padding:
                          EdgeInsets.only(top: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                      child: Text(
                        AyanamshaConstants.regionalInfo[selectedAyanamsha]!,
                        style: TextStyle(
                          fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_drop_down,
                  color: primaryColor, size: ResponsiveSystem.spacing(context, baseSpacing: 24)),
          ],
        ),
      ),
    );
  }
}

/// Ayanamsha selection dialog
class _AyanamshaSelectionDialog extends ConsumerWidget {
  final AyanamshaType selectedAyanamsha;
  final Function(AyanamshaType) onAyanamshaSelected;

  const _AyanamshaSelectionDialog({
    required this.selectedAyanamsha,
    required this.onAyanamshaSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(primaryColorProvider);
    final primaryTextColor = ref.watch(primaryTextColorProvider);
    final secondaryTextColor = ref.watch(secondaryTextColorProvider);

    return AlertDialog(
      backgroundColor: ThemeProperties.getSurfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
      ),
      title: Text(
        'Select Ayanamsha',
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
          fontWeight: FontWeight.w600,
          color: ThemeProperties.getPrimaryTextColor(context),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: AyanamshaType.values.length,
          itemBuilder: (context, index) {
            final ayanamsha = AyanamshaType.values[index];
            final isSelected = ayanamsha == selectedAyanamsha;

            return Card(
              color: isSelected ? primaryColor.withAlpha((0.1 * 255).round()) : null,
              margin:
                  EdgeInsets.symmetric(vertical: ResponsiveSystem.spacing(context, baseSpacing: 2)),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ResponsiveSystem.spacing(context, baseSpacing: 8)),
                side: isSelected
                    ? BorderSide(
                        color: primaryColor,
                        width: ResponsiveSystem.borderWidth(context, baseWidth: 2))
                    : BorderSide.none,
              ),
              child: EnhancedListTile<AyanamshaType>(
                value: ayanamsha,
                info: DropdownInfoAdapters.getAyanamshaInfo(ayanamsha),
                isSelected: isSelected,
                primaryColor: primaryColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                onTap: () {
                  onAyanamshaSelected(ayanamsha);
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
