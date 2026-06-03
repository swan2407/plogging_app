import 'package:flutter/material.dart';

import '../data/mock_map_data.dart';
import '../model/map_models.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);
  static const _inactive = Color(0xFFE5E7EB);

  final Set<MapLayer> _activeLayers = {MapLayer.groupPlogging};

  List<MapMarker> get _visibleMarkers {
    return mockMapMarkers
        .where((marker) => _activeLayers.contains(marker.layer))
        .toList();
  }

  String get _selectedLayerSummary {
    if (_activeLayers.isEmpty) {
      return '표시 중: 없음';
    }

    final selectedLabels = mapLayers
        .where((layer) => _activeLayers.contains(layer.layer))
        .map((layer) => layer.label)
        .join(', ');
    return '표시 중: $selectedLabels';
  }

  void _toggleLayer(MapLayer layer) {
    setState(() {
      if (_activeLayers.contains(layer)) {
        _activeLayers.remove(layer);
      } else {
        _activeLayers.add(layer);
      }
    });
  }

  void _moveToCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('현재 위치로 이동했어요.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleMarkers = _visibleMarkers;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            const _MapHeader(),
            const SizedBox(height: 18),
            _MapPlaceholder(summary: _selectedLayerSummary),
            const SizedBox(height: 18),
            _LayerToggleCard(
              activeLayers: _activeLayers,
              onLayerPressed: _toggleLayer,
            ),
            const SizedBox(height: 18),
            _LocationSummaryCard(
              activeLayerCount: _activeLayers.length,
              markerCount: visibleMarkers.length,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _moveToCurrentLocation,
                icon: const Icon(Icons.my_location, size: 22),
                label: const Text(
                  '내 위치로 이동',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 7,
                  shadowColor: _green.withValues(alpha: 0.24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _MarkerListSection(markers: visibleMarkers),
          ],
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지도',
          style: TextStyle(
            color: _MapScreenState._darkText,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '필요한 레이어만 켜고 주변 정보를 확인해보세요.',
          style: TextStyle(
            color: _MapScreenState._grayText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return _MapCard(
      padding: const EdgeInsets.all(18),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _MapScreenState._lightGreen,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _MapScreenState._green.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.map_outlined,
                color: _MapScreenState._green,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '지도 영역',
              style: TextStyle(
                color: _MapScreenState._darkText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '실제 지도 API는 이후 연결 예정',
              style: TextStyle(
                color: _MapScreenState._grayText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                summary,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _MapScreenState._green,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerToggleCard extends StatelessWidget {
  const _LayerToggleCard({
    required this.activeLayers,
    required this.onLayerPressed,
  });

  final Set<MapLayer> activeLayers;
  final ValueChanged<MapLayer> onLayerPressed;

  @override
  Widget build(BuildContext context) {
    return _MapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.layers_outlined, title: '레이어 선택'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final layer in mapLayers)
                _LayerToggleChip(
                  layer: layer,
                  selected: activeLayers.contains(layer.layer),
                  onPressed: () => onLayerPressed(layer.layer),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LayerToggleChip extends StatelessWidget {
  const _LayerToggleChip({
    required this.layer,
    required this.selected,
    required this.onPressed,
  });

  final MapLayerConfig layer;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _MapScreenState._green : _MapScreenState._inactive,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _MapScreenState._green
                : _MapScreenState._grayText.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              layer.icon,
              size: 18,
              color: selected ? Colors.white : _MapScreenState._grayText,
            ),
            const SizedBox(width: 7),
            Text(
              layer.label,
              style: TextStyle(
                color: selected ? Colors.white : _MapScreenState._grayText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSummaryCard extends StatelessWidget {
  const _LocationSummaryCard({
    required this.activeLayerCount,
    required this.markerCount,
  });

  final int activeLayerCount;
  final int markerCount;

  @override
  Widget build(BuildContext context) {
    return _MapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.place_outlined, title: '현재 위치'),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: _SummaryTile(
                  icon: Icons.near_me_outlined,
                  value: '마포구',
                  label: '현재 위치',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  icon: Icons.layers_outlined,
                  value: '$activeLayerCount개',
                  label: '표시 중인 레이어 수',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  icon: Icons.location_on_outlined,
                  value: '$markerCount개',
                  label: '주변 표시 항목 수',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarkerListSection extends StatelessWidget {
  const _MarkerListSection({required this.markers});

  final List<MapMarker> markers;

  @override
  Widget build(BuildContext context) {
    return _MapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.list_alt_outlined, title: '주변 항목'),
          const SizedBox(height: 14),
          if (markers.isEmpty)
            const _EmptyMarkerList()
          else
            for (var index = 0; index < markers.length; index++) ...[
              _MarkerListItem(marker: markers[index]),
              if (index != markers.length - 1) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _MarkerListItem extends StatelessWidget {
  const _MarkerListItem({required this.marker});

  final MapMarker marker;

  @override
  Widget build(BuildContext context) {
    final layer = mapLayers.firstWhere((item) => item.layer == marker.layer);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _MapScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(layer.icon, color: _MapScreenState._green, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layer.label,
                  style: const TextStyle(
                    color: _MapScreenState._green,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  marker.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _MapScreenState._darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  marker.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _MapScreenState._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            marker.distance,
            style: const TextStyle(
              color: _MapScreenState._darkText,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMarkerList extends StatelessWidget {
  const _EmptyMarkerList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: _MapScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '선택한 레이어가 없어 표시할 항목이 없습니다.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _MapScreenState._grayText,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _MapScreenState._lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _MapScreenState._green, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _MapScreenState._darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: _MapScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _MapScreenState._green, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _MapScreenState._darkText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _MapScreenState._grayText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
