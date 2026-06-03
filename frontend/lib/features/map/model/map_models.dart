import 'package:flutter/material.dart';

enum MapLayer { groupPlogging, trashRecord, recyclingStation, publicTrashCan }

class MapLayerConfig {
  const MapLayerConfig({
    required this.layer,
    required this.label,
    required this.icon,
  });

  final MapLayer layer;
  final String label;
  final IconData icon;
}

class MapMarker {
  const MapMarker({
    required this.layer,
    required this.title,
    required this.address,
    required this.distance,
  });

  final MapLayer layer;
  final String title;
  final String address;
  final String distance;
}
