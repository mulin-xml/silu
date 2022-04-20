// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:silu/amap.dart';

class AMapView extends StatefulWidget {
  const AMapView({Key? key}) : super(key: key);

  @override
  State<AMapView> createState() => _AMapViewState();
}

class _AMapViewState extends State<AMapView> {
  final _mark = <Marker>{};
  var _address = '';
  LatLng? _pos;

  @override
  void initState() {
    super.initState();
    Permission.location.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
        title: Text(_address),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop([_pos, _address]);
            },
            child: const Text('选择该位置'),
          ),
        ],
      ),
      body: AMapWidget(
        apiKey: AMapApiKey(androidKey: AMap().androidKey, iosKey: AMap().iosKey),
        privacyStatement: const AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
        initialCameraPosition: CameraPosition(target: AMap().lastLatLng, zoom: 18),
        mapType: MapType.normal,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        onLocationChanged: _onLocationChanged,
        onPoiTouched: _onMapPoiTouched,
        onTap: _onMapTap,
        markers: _mark,
        myLocationStyleOptions: MyLocationStyleOptions(
          true,
          circleFillColor: Colors.lightBlue,
          circleStrokeColor: Colors.blue,
          circleStrokeWidth: 1,
        ),
      ),
    );
  }

  void _onMapTap(LatLng? latLng) {
    if (latLng != null) {
      _mark.clear();
      _address = '地图选点';
      _pos = latLng;
      setState(() {
        _mark.add(Marker(
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      });
    }
  }

  void _onMapPoiTouched(AMapPoi? poi) {
    if (poi != null) {
      _mark.clear();
      _address = poi.name ?? '';
      _pos = poi.latLng;
      setState(() {
        _mark.add(Marker(
          position: poi.latLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      });
    }
  }

  _onLocationChanged(AMapLocation? location) {
    if (location != null) {
      AMap().lastLatLng = location.latLng;
    }
  }

  /// 获取审图号
  void getApprovalNumber() async {}
}
