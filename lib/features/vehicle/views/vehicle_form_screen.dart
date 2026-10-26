import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../customer/viewmodels/customer_viewmodel.dart';
import '../models/vehicle_models.dart';
import '../viewmodels/vehicle_viewmodel.dart';

/// Form screen for registering or editing a vehicle.
///
/// If [vehicleId] is non-null, this functions as an Edit form.
/// If [initialCustomerId] is non-null, it pre-fills the Customer ID.
class VehicleFormScreen extends ConsumerStatefulWidget {
  final int? vehicleId;
  final int? initialCustomerId;

  const VehicleFormScreen({super.key, this.vehicleId, this.initialCustomerId});

  bool get isEdit => vehicleId != null;

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCustomerId;
  bool _manualIdEntry = false;

  final _customerCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomerId != null) {
      _selectedCustomerId = widget.initialCustomerId;
      _customerCtrl.text = widget.initialCustomerId.toString();
    }
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _plateCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _vinCtrl.dispose();
    super.dispose();
  }

  void _populateFromVehicle(VehicleModel vehicle) {
    if (_initialized) return;
    _initialized = true;
    _selectedCustomerId = vehicle.customerId;
    _customerCtrl.text = vehicle.customerId.toString();
    _plateCtrl.text = vehicle.plateNumber;
    _makeCtrl.text = vehicle.make;
    _modelCtrl.text = vehicle.model;
    if (vehicle.year != null && vehicle.year! > 0) {
      _yearCtrl.text = vehicle.year.toString();
    }
    _colorCtrl.text = vehicle.color ?? '';
    _vinCtrl.text = vehicle.vin ?? '';
  }

  Future<void> _submit() async {
    ref.read(vehicleFormViewModelProvider.notifier).reset();
    if (!_formKey.currentState!.validate()) return;

    final customerId =
        _selectedCustomerId ?? int.tryParse(_customerCtrl.text.trim());
    if (customerId == null || customerId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter a valid Customer ID.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final plate = _plateCtrl.text.trim().toUpperCase();
    final make = _makeCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    final year = _yearCtrl.text.trim().isNotEmpty
        ? int.tryParse(_yearCtrl.text.trim())
        : null;
    final color = _colorCtrl.text.trim().isNotEmpty
        ? _colorCtrl.text.trim()
        : null;
    final vin = _vinCtrl.text.trim().isNotEmpty ? _vinCtrl.text.trim() : null;

    if (widget.isEdit) {
      await ref
          .read(vehicleFormViewModelProvider.notifier)
          .update(
            widget.vehicleId!,
            plateNumber: plate,
            make: make,
            model: model,
            year: year,
            color: color,
            vin: vin,
          );
    } else {
      await ref
          .read(vehicleFormViewModelProvider.notifier)
          .register(
            customerId: customerId,
            plateNumber: plate,
            make: make,
            model: model,
            year: year,
            color: color,
            vin: vin,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(vehicleFormViewModelProvider);
    final isLoading = formState is VehicleFormLoading;
    final customersAsync = ref.watch(customerListViewModelProvider);
    final customerList = customersAsync.valueOrNull?.customers ?? [];

    // If editing, load the existing vehicle data if not already populated
    if (widget.isEdit && !_initialized) {
      final existingVehicle = ref
          .watch(vehicleDetailViewModelProvider(widget.vehicleId!))
          .valueOrNull;
      if (existingVehicle != null) {
        _populateFromVehicle(existingVehicle);
      }
    }

    ref.listen<VehicleFormState>(vehicleFormViewModelProvider, (_, next) {
      if (next is VehicleFormSuccess) {
        final message = next.isEdit
            ? 'Vehicle ${next.vehicle.plateNumber} updated successfully.'
            : 'Vehicle ${next.vehicle.plateNumber} registered successfully.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Refresh list and detail views
        ref.read(vehicleListViewModelProvider.notifier).refresh();
        if (widget.isEdit) {
          ref
              .read(vehicleDetailViewModelProvider(widget.vehicleId!).notifier)
              .refresh(widget.vehicleId!);
          context.pop();
        } else {
          context.pop();
          context.push(AppRoutes.vehicleDetail(next.vehicle.id));
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Vehicle' : 'Register Vehicle'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Required Section ──────────────────────────────
              _SectionLabel(label: 'Required Information'),
              const SizedBox(height: 12),

              // Customer Selection / ID
              if (widget.isEdit)
                TextFormField(
                  controller: _customerCtrl,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Customer ID',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                )
              else if (!_manualIdEntry && customerList.isNotEmpty) ...[
                DropdownButtonFormField<int>(
                  initialValue:
                      _selectedCustomerId != null &&
                          customerList.any((c) => c.id == _selectedCustomerId)
                      ? _selectedCustomerId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Select Customer *',
                    hintText: 'Choose registered customer',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: customerList.map((c) {
                    return DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(
                        '${c.displayName} (ID: ${c.id})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (val) {
                          setState(() {
                            _selectedCustomerId = val;
                            if (val != null) {
                              _customerCtrl.text = val.toString();
                            }
                          });
                        },
                  validator: (v) {
                    if (v == null &&
                        (_selectedCustomerId == null ||
                            _selectedCustomerId! <= 0)) {
                      return 'Please select a customer.';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => setState(() => _manualIdEntry = true),
                    child: const Text(
                      'Enter ID manually',
                      style: TextStyle(fontSize: 12, color: AppColors.gold),
                    ),
                  ),
                ),
              ] else ...[
                TextFormField(
                  controller: _customerCtrl,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Customer ID',
                    hintText: 'Enter customer ID (e.g. 15)',
                    prefixIcon: const Icon(Icons.person_outline),
                    suffixIcon: customerList.isNotEmpty
                        ? TextButton(
                            onPressed: () => setState(() {
                              _manualIdEntry = false;
                              if (_customerCtrl.text.isNotEmpty) {
                                _selectedCustomerId = int.tryParse(
                                  _customerCtrl.text.trim(),
                                );
                              }
                            }),
                            child: const Text(
                              'Select list',
                              style: TextStyle(fontSize: 12),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (v) {
                    _selectedCustomerId = int.tryParse(v.trim());
                  },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Customer ID is required.';
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return 'Enter a valid numeric Customer ID.';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 14),

              // Plate Number
              TextFormField(
                controller: _plateCtrl,
                enabled: !isLoading,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  hintText: 'e.g. DXB-A-12345',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Plate number is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Make
              TextFormField(
                controller: _makeCtrl,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Make',
                  hintText: 'e.g. Toyota, Nissan, BMW',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Make is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Model
              TextFormField(
                controller: _modelCtrl,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'e.g. Camry, Patrol, X5',
                  prefixIcon: Icon(Icons.commute_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Model is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Optional Section ──────────────────────────────
              _SectionLabel(label: 'Optional Details'),
              const SizedBox(height: 12),

              // Year
              TextFormField(
                controller: _yearCtrl,
                enabled: !isLoading,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Model Year',
                  hintText: 'e.g. 2023',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final yr = int.tryParse(v.trim());
                    if (yr == null || yr < 1900 || yr > 2100) {
                      return 'Enter a year between 1900 and 2100.';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Color
              TextFormField(
                controller: _colorCtrl,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  hintText: 'e.g. White, Silver, Black',
                  prefixIcon: Icon(Icons.palette_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // VIN
              TextFormField(
                controller: _vinCtrl,
                enabled: !isLoading,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'VIN / Chassis Number',
                  hintText: 'Vehicle Identification Number',
                  prefixIcon: Icon(Icons.fingerprint),
                ),
                validator: (v) {
                  if (v != null && v.trim().length > 50) {
                    return 'VIN cannot exceed 50 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // ── Error Banner ──────────────────────────────────
              if (formState is VehicleFormError) ...[
                _ErrorBanner(message: formState.message),
                const SizedBox(height: 20),
              ],

              // ── Submit Button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          widget.isEdit ? 'Save Changes' : 'Register Vehicle',
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Form Widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
