import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/service_record.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceRecord service;

  const ServiceDetailScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.serviceDetail),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info Card
            _buildBasicInfoCard(),

            const SizedBox(height: 16),

            // Operations Card
            _buildOperationsCard(),

            const SizedBox(height: 16),

            // Parts Card (if available)
            if (service.parts != null && service.parts!.isNotEmpty) ...[
              _buildPartsCard(),
              const SizedBox(height: 16),
            ],

            // Amount Card
            _buildAmountCard(),

            const SizedBox(height: 16),

            // Documents Button
            _buildDocumentsButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Servis Bilgileri',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: AppStrings.date,
              value: service.formattedDate,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.speed,
              label: AppStrings.mileage,
              value: service.formattedMileage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.operations,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            Text(
              service.operations,
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.parts,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            Text(
              service.parts!,
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.totalAmount,
              style: AppTextStyles.heading3,
            ),
            Text(
              service.formattedAmount,
              style: AppTextStyles.heading2.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Navigate to documents screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Belgeler ekranı yakında eklenecek'),
            ),
          );
        },
        icon: const Icon(Icons.description),
        label: const Text(AppStrings.viewDocuments),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.gray600,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.gray600,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
