import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch vehicles
  Future<void> fetchVehicles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Dummy data for testing
      _vehicles = [
        Vehicle(
          id: 1,
          licensePlate: '34 ABC 123',
          brand: 'Toyota',
          model: 'Corolla',
          vin: 'JT123456789012345',
          currentStatus: 'in_progress',
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
          serviceCount: 3,
        ),
        Vehicle(
          id: 2,
          licensePlate: '35 XYZ 789',
          brand: 'Volkswagen',
          model: 'Passat',
          vin: 'WVW98765432109876',
          currentStatus: 'ready',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
          serviceCount: 5,
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get vehicle by ID
  Vehicle? getVehicleById(int id) {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh vehicles
  Future<void> refresh() async {
    await fetchVehicles();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
