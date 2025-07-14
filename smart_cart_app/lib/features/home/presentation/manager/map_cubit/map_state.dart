import 'package:equatable/equatable.dart';
import 'package:smart_cart_app/features/home/data/models/map_model_types.dart';
import 'package:smart_cart_app/features/home/data/models/map_search_product_model/map_search_product_model.dart';

class MapState extends Equatable {
  final Coordinates userPosition;
  final MapSearchProductModel? selectedProduct;
  final List<MapSearchProductModel> searchResults;
  final List<List<int>> path;
  final bool isOnline;
  final String error;
  final String currentGeofence;
  final bool isWifiEnabled;
  final bool hasPermissions;
  final bool isWifiManagerNull;
  final bool manualMode;
  final bool isLoading;

  const MapState({
    this.userPosition = const Coordinates(x: 1, y: 0),
    this.selectedProduct,
    this.path = const [],
    this.isOnline = true,
    this.error = '',
    this.currentGeofence = '',
    this.isWifiEnabled = false,
    this.hasPermissions = false,
    this.isWifiManagerNull = false,
    this.manualMode = false,
    this.isLoading = false,
    this.searchResults = const [],
  });

  MapState copyWith({
    Coordinates? userPosition,
    MapSearchProductModel? selectedProduct,
    List<List<int>>? path,
    bool? isOnline,
    String? error,
    String? currentGeofence,
    bool? isWifiEnabled,
    bool? hasPermissions,
    bool? isWifiManagerNull,
    bool? manualMode,
    bool? isLoading,
    List<MapSearchProductModel>? searchResults,
  }) {
    return MapState(
      userPosition: userPosition ?? this.userPosition,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      path: path ?? this.path,
      isOnline: isOnline ?? this.isOnline,
      error: error ?? this.error,
      currentGeofence: currentGeofence ?? this.currentGeofence,
      isWifiEnabled: isWifiEnabled ?? this.isWifiEnabled,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      isWifiManagerNull: isWifiManagerNull ?? this.isWifiManagerNull,
      manualMode: manualMode ?? this.manualMode,
      isLoading: isLoading ?? this.isLoading,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object?> get props => [
        userPosition,
        selectedProduct,
        path,
        isOnline,
        error,
        currentGeofence,
        isWifiEnabled,
        hasPermissions,
        isWifiManagerNull,
        manualMode,
        isLoading,
        searchResults,
      ];
}
