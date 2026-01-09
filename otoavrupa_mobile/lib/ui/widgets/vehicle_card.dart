import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: License Plate & Status
              Row(
                children: [
                  // License Plate
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vehicle.formattedLicensePlate,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Status Badge
                  _buildStatusBadge(),
                ],
              ),

              const SizedBox(height: 16),

              // Vehicle Info: Brand & Model
              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: AppTheme.gray600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vehicle.fullName,
                      style: AppTextStyles.titleLarge,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // VIN
              Row(
                children: [
                  const Icon(
                    Icons.confirmation_number,
                    color: AppTheme.gray600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppStrings.vin}: ${vehicle.vin}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Service Count (if available)
              if (vehicle.serviceCount != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.build,
                      color: AppTheme.gray600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${vehicle.serviceCount} Servis Kaydı',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Last Updated
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: AppTheme.gray600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatLastUpdated(vehicle.lastUpdated),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Divider
              const Divider(height: 1),

              const SizedBox(height: 8),

              // View Details Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    AppStrings.vehicleDetail,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = StatusHelper.getStatusColor(vehicle.currentStatus);
    final statusText = StatusHelper.getStatusText(vehicle.currentStatus);
    final statusIcon = StatusHelper.getStatusIcon(vehicle.currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: AppTextStyles.bodySmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Az önce güncellendi';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes dakika önce güncellendi';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours saat önce güncellendi';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year} tarihinde güncellendi';
    }
  }
}
