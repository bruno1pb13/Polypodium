import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';

class DeviceCoordinates {
  final double latitude;
  final double longitude;

  const DeviceCoordinates({required this.latitude, required this.longitude});
}

class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);

  @override
  String toString() => message;
}

abstract interface class ILocationService {
  Future<DeviceCoordinates> getCurrentPosition();
}

class GeolocatorLocationService implements ILocationService {
  const GeolocatorLocationService();

  @override
  Future<DeviceCoordinates> getCurrentPosition() async {
    if (Platform.isLinux) {
      throw const LocationServiceException(
          'Geolocalização não é suportada no desktop Linux.');
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
          'O GPS está desativado. Ative-o e tente novamente.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(
            'Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
          'Permissão de localização negada permanentemente. Habilite nas configurações do dispositivo.');
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
