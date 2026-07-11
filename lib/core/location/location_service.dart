import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';

class DeviceCoordinates {
  final double latitude;
  final double longitude;

  const DeviceCoordinates({required this.latitude, required this.longitude});
}

/// Why obtaining the device position failed. The UI maps each code to a
/// localized message.
enum LocationError {
  unsupportedPlatform,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class LocationServiceException implements Exception {
  final LocationError error;
  const LocationServiceException(this.error);

  @override
  String toString() => 'LocationServiceException($error)';
}

abstract interface class ILocationService {
  Future<DeviceCoordinates> getCurrentPosition();
}

class GeolocatorLocationService implements ILocationService {
  const GeolocatorLocationService();

  @override
  Future<DeviceCoordinates> getCurrentPosition() async {
    if (Platform.isLinux) {
      throw const LocationServiceException(LocationError.unsupportedPlatform);
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(LocationError.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(LocationError.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
          LocationError.permissionDeniedForever);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return DeviceCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
