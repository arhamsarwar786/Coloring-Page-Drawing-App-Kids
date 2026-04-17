import 'package:flutter/material.dart';

import 'skin_model.dart';

abstract final class SkinCatalog {
  static const List<SkinModel> items = <SkinModel>[
    SkinModel(
      id: 'marker',
      image: 'assets/images/marker.png',
      barrelColor: Color(0xFFFF3A3A),
      capColor: Color(0xFF3B3B3B),
    ),
    SkinModel(
      id: 'marker1',
      image: 'assets/images/marker1.png',
      barrelColor: Color(0xFF48E141),
      capColor: Color(0xFF76FF6E),
      requiresAd: true,
    ),
    SkinModel(
      id: 'markerf',
      image: 'assets/images/markerf.png',
      barrelColor: Color(0xFFFFFFFF),
      capColor: Color(0xFFE3C2FF),
      requiresAd: true,
      face: true,
    ),
    SkinModel(
      id: 'markerfi',
      image: 'assets/images/markerfi.png',
      barrelColor: Color(0xFFFF5858),
      capColor: Color(0xFF1E1E1E),
      bandColor: Color(0xFFD8D8D8),
      requiresAd: true,
    ),
    SkinModel(
      id: 'markerp',
      image: 'assets/images/markerp.png',
      barrelColor: Color(0xFFFFFFFF),
      capColor: Color(0xFFE53935),
      bandColor: Color(0xFFFFD0D0),
      requiresAd: true,
    ),
    SkinModel(
      id: 'markers',
      image: 'assets/images/markers.png',
      barrelColor: Color(0xFFFFB33B),
      capColor: Color(0xFFFFD34F),
      bandColor: Color(0xFFFF8A65),
      requiresAd: true,
    ),
    SkinModel(
      id: 'markerse',
      image: 'assets/images/markerse.png',
      barrelColor: Color(0xFF23C8FF),
      capColor: Color(0xFF4DD0E1),
      requiresAd: true,
    ),
    SkinModel(
      id: 'markert',
      image: 'assets/images/markert.png',
      barrelColor: Color(0xFFAB47BC),
      capColor: Color(0xFFE1BEE7),
      face: true,
    ),
    SkinModel(
      id: 'markerth',
      image: 'assets/images/markerth.png',
      barrelColor: Color(0xFFFF8A80),
      capColor: Color(0xFFFFCCBC),
      requiresAd: true,
    ),
  ];

  static SkinModel byId(String id) {
    return items.firstWhere(
      (skin) => skin.id == id,
      orElse: () => items.first,
    );
  }
}
