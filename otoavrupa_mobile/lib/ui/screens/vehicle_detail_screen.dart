import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/vehicle.dart';
import '../widgets/vehicle_info_card.dart';
import 'service_history_screen.dart';
import 'documents_screen.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.formattedLicensePlate),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Info Card
            VehicleInfoCard(vehicle: vehicle),

            const SizedBox(height: 24),

            // Actions Section
            _buildActionsSection(context),

            const SizedBox(height: 24),

            // Status Timeline
            _buildStatusSection(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İşlemler',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.history,
                label: AppStrings.serviceHistory,
                onTap: () => _navigateToServiceHistory(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.description,
                label: AppStrings.documents,
                onTap: () => _navigateToDocuments(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final statusColor = StatusHelper.getStatusColor(vehicle.currentStatus);
    final statusText = StatusHelper.getStatusText(vehicle.currentStatus);
    final statusIcon = StatusHelper.getStatusIcon(vehicle.currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durum',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                statusIcon,
                size: 48,
                color: statusColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: AppTextStyles.heading2.copyWith(
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLastUpdated(vehicle.lastUpdated),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Az önce güncellendi';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes dakika önce';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours saat önce';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  void _navigateToServiceHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceHistoryScreen(vehicle: vehicle),
      ),
    );
  }

  void _navigateToDocuments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentsScreen(vehicle: vehicle),
      ),
    );
  }
}
