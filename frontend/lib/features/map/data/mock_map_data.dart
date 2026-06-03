import 'package:flutter/material.dart';

import '../model/map_models.dart';

const mapLayers = [
  MapLayerConfig(
    layer: MapLayer.groupPlogging,
    label: '단체 플로깅',
    icon: Icons.groups_outlined,
  ),
  MapLayerConfig(
    layer: MapLayer.trashRecord,
    label: '쓰레기 기록',
    icon: Icons.delete_outline,
  ),
  MapLayerConfig(
    layer: MapLayer.recyclingStation,
    label: '분리수거장',
    icon: Icons.recycling_outlined,
  ),
  MapLayerConfig(
    layer: MapLayer.publicTrashCan,
    label: '공공 쓰레기통',
    icon: Icons.delete_sweep_outlined,
  ),
];

const mockMapMarkers = [
  MapMarker(
    layer: MapLayer.groupPlogging,
    title: '상암 하늘공원 저녁 플로깅',
    address: '서울 마포구 하늘공원로',
    distance: '450m',
  ),
  MapMarker(
    layer: MapLayer.groupPlogging,
    title: '홍대입구 골목 정화 모임',
    address: '서울 마포구 양화로',
    distance: '1.1km',
  ),
  MapMarker(
    layer: MapLayer.trashRecord,
    title: '담배꽁초 집중 발견 구역',
    address: '서울 마포구 월드컵북로',
    distance: '320m',
  ),
  MapMarker(
    layer: MapLayer.trashRecord,
    title: '일회용 컵 수거 기록',
    address: '서울 마포구 성미산로',
    distance: '780m',
  ),
  MapMarker(
    layer: MapLayer.recyclingStation,
    title: '망원1동 분리수거장',
    address: '서울 마포구 포은로',
    distance: '620m',
  ),
  MapMarker(
    layer: MapLayer.recyclingStation,
    title: '상수역 재활용 수거함',
    address: '서울 마포구 독막로',
    distance: '1.4km',
  ),
  MapMarker(
    layer: MapLayer.publicTrashCan,
    title: '망원한강공원 공공 쓰레기통',
    address: '서울 마포구 마포나루길',
    distance: '950m',
  ),
  MapMarker(
    layer: MapLayer.publicTrashCan,
    title: '합정역 6번 출구 쓰레기통',
    address: '서울 마포구 양화로',
    distance: '1.7km',
  ),
];
