import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/vehicle.dart';
import '../../models/service_record.dart';
import 'service_detail_screen.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final Vehicle vehicle;

  const ServiceHistoryScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  // TODO: Replace with actual data from API
  final List<ServiceRecord> _dummyServices = [];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Dummy data for UI testing
    _dummyServices.addAll([
      ServiceRecord(
        id: 1,
        vehicleId: widget.vehicle.id,
        serviceDate: DateTime.now().subtract(const Duration(days: 30)),
        mileage: 50000,
        operations: 'Yağ değişimi, Filtre değişimi, Rot ayarı',
        parts: 'Motor yağı, Yağ filtresi, Hava filtresi',
        totalAmount: 3500.00,
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ServiceRecord(
        id: 2,
        vehicleId: widget.vehicle.id,
        serviceDate: DateTime.now().subtract(const Duration(days: 120)),
        mileage: 45000,
        operations: 'Periyodik bakım, Fren kontrolü',
        parts: 'Fren balatası önlık',
        totalAmount: 4200.50,
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
    ]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.serviceHistory),
      ),
      body: _dummyServices.isEmpty
          ? _buildEmptyWidget()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _dummyServices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final service = _dummyServices[index];
                return _buildServiceCard(service);
              },
            ),
    );
  }

  Widget _buildServiceCard(ServiceRecord service) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToServiceDetail(service),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date & Mileage Row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppTheme.gray600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service.formattedDate,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.speed,
                    size: 20,
                    color: AppTheme.gray600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service.formattedMileage,
                    style: AppTextStyles.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Operations Preview
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.build,
                    size: 20,
                    color: AppTheme.gray600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.operations,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Total Amount
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 20,
                    color: AppTheme.gray600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service.formattedAmount,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // View Details Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Detayları gör',
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

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
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
            'Servis geçmişi bulunamadı',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  void _navigateToServiceDetail(ServiceRecord service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }
}
