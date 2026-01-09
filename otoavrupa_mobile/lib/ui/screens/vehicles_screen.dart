import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../widgets/vehicle_card.dart';
import 'vehicle_detail_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch vehicles on init
    Future.microtask(() {
      context.read<VehicleProvider>().fetchVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myVehicles),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VehicleProvider>().refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          // Loading
          if (vehicleProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (vehicleProvider.errorMessage != null) {
            return _buildErrorWidget(vehicleProvider);
          }

          // Empty
          if (vehicleProvider.vehicles.isEmpty) {
            return _buildEmptyWidget();
          }

          // Success - List of vehicles
          return RefreshIndicator(
            onRefresh: () => vehicleProvider.refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vehicleProvider.vehicles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final vehicle = vehicleProvider.vehicles[index];
                return VehicleCard(
                  vehicle: vehicle,
                  onTap: () => _navigateToVehicleDetail(vehicle),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(VehicleProvider vehicleProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            vehicleProvider.errorMessage ?? AppStrings.error,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: vehicleProvider.clearError,
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: AppTheme.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noData,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kayıtlı araç bulunamadı',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  void _navigateToVehicleDetail(Vehicle vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetailScreen(vehicle: vehicle),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout
            },
            child: const Text(
              AppStrings.confirm,
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
