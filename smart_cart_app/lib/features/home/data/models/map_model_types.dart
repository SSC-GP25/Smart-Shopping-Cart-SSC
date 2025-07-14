class Coordinates {
  final int x;
  final int y;

  const Coordinates({required this.x, required this.y});

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  @override
  bool operator ==(Object other) =>
      other is Coordinates && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

class WifiScanResult {
  final int RSSI;
  final String BSSID;
  final String SSID;

  WifiScanResult({required this.BSSID, required this.RSSI, required this.SSID});
}

class Product {
  final String name;
  final String aisle;
  final Coordinates coordinates;

  Product({required this.name, required this.aisle, required this.coordinates});

  @override
  bool operator ==(Object other) =>
      other is Product &&
      name == other.name &&
      aisle == other.aisle &&
      coordinates == other.coordinates;

  @override
  int get hashCode => Object.hash(name, aisle, coordinates);
}

class AccessPoint {
  final String mac;
  final int x;
  final int y;

  AccessPoint({required this.mac, required this.x, required this.y});
}

class Bounds {
  final int minX;
  final int minY;
  final int maxX;
  final int maxY;

  Bounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });
}

class Geofence {
  final String label;
  final Bounds bounds;

  Geofence({required this.label, required this.bounds});
}
