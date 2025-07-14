import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_cart_app/core/services/map_consts.dart';
import 'package:smart_cart_app/features/home/data/models/map_model_types.dart';
import 'package:smart_cart_app/features/home/data/models/map_search_product_model/map_search_product_model.dart';
import 'package:smart_cart_app/features/home/data/repos/home_repo.dart';
import 'package:smart_cart_app/features/home/presentation/manager/map_cubit/map_state.dart';
import 'package:smart_cart_app/features/home/presentation/views/widgets/map_kalman_filter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_scan/wifi_scan.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit(this.homeRepo) : super(const MapState());

  static MapCubit get(context) => BlocProvider.of(context);
  HomeRepo homeRepo;
  Timer? _scanTimer;
  Timer? _debounce;
  StreamSubscription? _connectivitySubscription;
  KalmanFilter? _xFilter;
  KalmanFilter? _yFilter;
  @override
  Future<void> close() {
    _scanTimer?.cancel();
    _debounce?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));
    await _checkWifiManagerAvailability();
    if (!state.isWifiManagerNull) {
      await checkAndRequestPermissions();
      await initializeWifi();
    }
    _monitorNetwork();
    _monitorWifiState();
    if (!state.isWifiManagerNull &&
        state.hasPermissions &&
        state.isWifiEnabled) {
      _startWifiScanning();
    }
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _checkWifiManagerAvailability() async {
    const isAvailable = true;
    emit(
      state.copyWith(
        isWifiManagerNull: !isAvailable,
        error: !isAvailable
            // ignore: dead_code
            ? 'Wi-Fi scanning is not available. Please check your setup.'
            : '',
        manualMode: !isAvailable,
      ),
    );
  }

  Future<void> checkAndRequestPermissions() async {
    final permissions = [
      Permission.location,
      Permission.nearbyWifiDevices,
      Permission.notification,
    ];
    final status = await permissions.request();
    final allGranted = status.values.every((s) => s.isGranted);
    emit(
      state.copyWith(
        hasPermissions: allGranted,
        error: allGranted ? '' : 'Location and Wi-Fi permissions are required.',
      ),
    );
  }

  Future<void> initializeWifi() async {
    try {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        emit(
          state.copyWith(
            isWifiEnabled: false,
            error: 'Wi-Fi is disabled. Please enable Wi-Fi.',
          ),
        );
        await _openWifiSettings();
        return;
      }
      emit(state.copyWith(isWifiEnabled: true, error: ''));
    } catch (e) {
      emit(
        state.copyWith(
          isWifiEnabled: false,
          error: 'Failed to initialize Wi-Fi: $e',
        ),
      );
    }
  }

  Future<void> _openWifiSettings() async {
    const url = 'app-settings:';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      emit(
        state.copyWith(
          error: 'Unable to open Wi-Fi settings. Please enable Wi-Fi manually.',
        ),
      );
    }
  }

  void _monitorNetwork() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final isOnline = results.any(
        (result) => result != ConnectivityResult.none,
      );
      emit(state.copyWith(isOnline: isOnline));
    });
  }

  Future<void> _monitorWifiState() async {
    if (state.isWifiManagerNull || isClosed) return;
    try {
      final canScan = await WiFiScan.instance.canStartScan();
      final isEnabled = canScan == CanStartScan.yes;
      if (isClosed) return;
      emit(
        state.copyWith(
          isWifiEnabled: isEnabled,
          error: isEnabled ? '' : 'Wi-Fi is disabled. Please enable Wi-Fi.',
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(error: 'Error checking Wi-Fi status: $e'));
    }

    if (!isClosed) {
      Timer(const Duration(seconds: 5), _monitorWifiState);
    }
  }

  void _startWifiScanning() {
    _scanTimer?.cancel();
    _scanWifi();
    _scanTimer = Timer.periodic(
      const Duration(milliseconds: MapConstants.scanInterval),
      (_) {
        _scanWifi();
      },
    );
  }

  Future<void> _scanWifi() async {
    if (state.isWifiManagerNull ||
        !state.hasPermissions ||
        !state.isWifiEnabled) {
      emit(
        state.copyWith(
          error: 'Cannot scan: Missing manager, permissions, or Wi-Fi.',
        ),
      );
      return;
    }

    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) {
      emit(state.copyWith(error: 'Cannot start scan: ${canScan.name}'));
      return;
    }
    try {
      final success = await WiFiScan.instance.startScan();
      if (!success) {
        emit(state.copyWith(error: 'Failed to start Wi-Fi scan.'));
        return;
      }

      final wifiList = await WiFiScan.instance.getScannedResults();
      final scanResults = wifiList
          .map(
            (ap) => WifiScanResult(
              BSSID: ap.bssid,
              RSSI: ap.level,
              SSID: ap.ssid,
            ),
          )
          .toList();
      final newPosition = _calculatePosition(scanResults);
      if (newPosition != null) {
        emit(state.copyWith(userPosition: newPosition));
        _checkGeofence(newPosition);
        if (state.selectedProduct != null) {
          await findPath();
        }
      }
    } catch (e) {
      emit(state.copyWith(error: 'Wi-Fi scanning error: $e'));
    }
  }

  Coordinates? _calculatePosition(List<WifiScanResult> scanResults) {
    final positions = <Map<String, dynamic>>[];
    for (var result in scanResults) {
      final ap = accessPoints.firstWhere(
        (ap) => ap.mac == result.BSSID,
        orElse: () => AccessPoint(mac: '', x: 0, y: 0),
      );
      // print('AP: ${ap.mac}, RSSI: ${result.RSSI}, Coordinates: (${ap.x}, ${ap.y})');
      if (ap.mac.isNotEmpty) {
        const rssiAtOneMeter = -45; // or -40
        const pathLossExponent =
            2.2; // Try 2.0 to 3.5 depending on wall density
        final distance = pow(
          10,
          (rssiAtOneMeter - result.RSSI) / (10 * pathLossExponent),
        ).toDouble();
        // final distance = pow(10, (-50 - result.RSSI) / 20).toDouble();
        final weight = 1 / (distance * distance);
        positions.add({'x': ap.x, 'y': ap.y, 'weight': weight});
        print('Distance: $distance, Weight: $weight, x: ${ap.x}, y: ${ap.y}');
      }
    }
    if (positions.isEmpty) return null;

    final totalWeight = positions.fold(0.0, (sum, pos) => sum + pos['weight']);
    var x = (positions.fold(0.0, (sum, pos) => sum + pos['x'] * pos['weight']) /
        totalWeight);
    var y = (positions.fold(0.0, (sum, pos) => sum + pos['y'] * pos['weight']) /
        totalWeight);

    _xFilter ??= KalmanFilter(initialValue: x);
    _yFilter ??= KalmanFilter(initialValue: y);

    final filteredX = _xFilter!.filter(x).floor();
    final filteredY = _yFilter!.filter(y).floor();

    if (filteredX >= 0 &&
        filteredX < 25 &&
        filteredY >= 0 &&
        filteredY < 44 &&
        grid[filteredY][filteredX] == 0) {
      return Coordinates(x: filteredX, y: filteredY);
    }
    return null;
  }

  void _checkGeofence(Coordinates position) {
    for (var fence in geofences) {
      final isInside = position.x >= fence.bounds.minX &&
          position.x <= fence.bounds.maxX &&
          position.y >= fence.bounds.minY &&
          position.y <= fence.bounds.maxY;
      if (isInside) {
        if (state.currentGeofence != fence.label) {
          emit(state.copyWith(currentGeofence: fence.label));
          // Show alert (handled in UI)
        }
        return;
      }
    }
    if (state.currentGeofence.isNotEmpty) {
      emit(state.copyWith(currentGeofence: ''));
      // Show alert (handled in UI)
    }
  }

  Future<void> findPath() async {
    if (state.selectedProduct == null) return;
    try {
      var result = await homeRepo.findPath(
        start: state.userPosition,
        end: Coordinates(
          x: state.selectedProduct!.x!,
          y: state.selectedProduct!.y!,
        ),
      );
      result.fold(
        (failure) {
          emit(state.copyWith(error: failure.toString()));
        },
        (path) {
          emit(state.copyWith(path: path, error: ''));
        },
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to find path: $e'));
    }
  }

  void selectProduct(MapSearchProductModel? product) {
    print("in Select Product");
    emit(state.copyWith(selectedProduct: product));
  }

  void searchProducts(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        // Example: Perform your real API request here
        if (query.trim() == 0) {
          emit(state.copyWith(searchResults: []));
          return;
        }
        var result = await homeRepo.getSearchedProducts(query: query);
        result.fold(
          (failure) => emit(state.copyWith(error: failure.toString())),
          (products) {
            emit(state.copyWith(searchResults: products, error: ''));
            print("Search Now");
          },
        );
      } catch (e) {
        emit(state.copyWith(error: 'Search error: $e'));
      }
    });
  }

  void clearSearchResults() {
    emit(state.copyWith(searchResults: []));
  }
}
