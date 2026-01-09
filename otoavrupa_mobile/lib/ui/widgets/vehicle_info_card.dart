import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/vehicle.dart';

class VehicleInfoCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleInfoCard({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // License Plate
            _buildInfoRow(
              icon: Icons.badge,
              label: AppStrings.licensePlate,
              value: vehicle.formattedLicensePlate,
              valueStyle: AppTextStyles.heading3.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(height: 32),

            // Brand & Model
            _buildInfoRow(
              icon: Icons.directions_car,
              label: '${AppStrings.brand} / ${AppStrings.model}',
              value: vehicle.fullName,
            ),

            const SizedBox(height: 16),

            // VIN
            _buildInfoRow(
              icon: Icons.confirmation_number,
              label: AppStrings.vin,
              value: vehicle.vin,
              valueStyle: AppTextStyles.bodyMedium.copyWith(
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),

            // Service Count (if available)
            if (vehicle.serviceCount != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.build,
                label: 'Toplam Servis',
                value: '${vehicle.serviceCount} kayıt',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.gray600,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.gray600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ?? AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
