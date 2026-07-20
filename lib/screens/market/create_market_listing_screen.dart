import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class CreateMarketListingScreen extends StatefulWidget {
  const CreateMarketListingScreen({super.key});

  @override
  State<CreateMarketListingScreen> createState() => _CreateMarketListingScreenState();
}

class _CreateMarketListingScreenState extends State<CreateMarketListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _category = 'Crops';
  String _unit = 'quintal';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submitListing() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Market listing created successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Create Listing',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'List Product for Sale or Rent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkGreen,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 16),

              // Category Selector
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Listing Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'Crops', child: Text('Crops / Harvest')),
                  DropdownMenuItem(value: 'Seeds', child: Text('Seeds')),
                  DropdownMenuItem(value: 'Fertilizers', child: Text('Fertilizers')),
                  DropdownMenuItem(value: 'Machinery', child: Text('Machinery Rental')),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ).animate().fadeIn(delay: 50.ms),

              const SizedBox(height: 16),

              // Product Name
              FarmTextField(
                controller: _nameCtrl,
                label: 'Listing Title',
                hint: 'e.g. Sonalika Wheat Grain / Mini Tractor',
                prefixIcon: Icons.shopping_bag_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              // Price & Quantity Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FarmTextField(
                      controller: _priceCtrl,
                      label: 'Price (₹)',
                      hint: 'e.g. 1800',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.currency_rupee_rounded,
                      validator: (val) => val == null || val.isEmpty ? 'Enter price' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Per Unit',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'quintal', child: Text('/ quintal')),
                        DropdownMenuItem(value: 'kg', child: Text('/ kg')),
                        DropdownMenuItem(value: 'ton', child: Text('/ ton')),
                        DropdownMenuItem(value: 'day', child: Text('/ day (Rent)')),
                      ],
                      onChanged: (v) => setState(() => _unit = v!),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 16),

              // Quantity Input
              FarmTextField(
                controller: _quantityCtrl,
                label: 'Available Quantity',
                hint: 'e.g. 25',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.production_quantity_limits_rounded,
                validator: (val) => val == null || val.isEmpty ? 'Enter quantity' : null,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // Location Input
              FarmTextField(
                controller: _locationCtrl,
                label: 'Pick-up Location / Market',
                hint: 'e.g. Salem Market, Tamil Nadu',
                prefixIcon: Icons.location_on_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Enter location' : null,
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 16),

              // Description
              FarmTextField(
                controller: _descriptionCtrl,
                label: 'Product Details / Quality Description',
                hint: 'Provide details about grain moisture, seed certification, machinery age, etc.',
                maxLines: 4,
                prefixIcon: Icons.description_outlined,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Upload Photo Widget
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryGreen, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Image (Optional)',
                        style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 32),

              // Submit Button
              LoadingButton(
                isLoading: _isSaving,
                onPressed: _submitListing,
                label: 'Publish Listing',
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
