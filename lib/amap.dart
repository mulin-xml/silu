// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:silu/event_bus.dart';

class AMap {
  static getInstance() => _instance;
  static final _instance = AMap._internal();
  factory AMap() => getInstance();
  AMap._internal() {
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    _requestLocationPermission(); // 动态申请定位权限
    AMapFlutterLocation.setApiKey(androidKey, iosKey);
    // iOS 获取native精度类型
    if (Platform.isIOS) {
      _requestAccuracyAuthorization();
    }
    // 注册定位结果监听
    _locationListener = _locationPlugin.onLocationChanged().listen((Map<String, dynamic> result) {
      location = result;
      lastLatLng = LatLng(result['latitude'], result['longitude']);
      if (result['accuracy'] < 200) {
        bus.emit('discover_page_update');
        stopLocation();
      }
    });
  }

  StreamSubscription<Map<String, Object>>? _locationListener;
  final _locationPlugin = AMapFlutterLocation();
  Map<String, dynamic> location = {};
  LatLng lastLatLng = const LatLng(39.909187, 116.397451);
  final androidKey = "0f85c261d48608ece2b180d7778d6861";
  final iosKey = '';

  dispose() {
    _locationListener?.cancel(); // 移除定位监听
    _locationPlugin.destroy(); // 销毁定位
  }

  ///设置定位参数
  _setLocationOption() {
    AMapLocationOption locationOption = AMapLocationOption();

    ///是否单次定位
    locationOption.onceLocation = false;

    ///是否需要返回逆地理信息
    locationOption.needAddress = true;

    ///逆地理信息的语言类型
    locationOption.geoLanguage = GeoLanguage.DEFAULT;
    locationOption.desiredLocationAccuracyAuthorizationMode = AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;
    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

    ///设置Android端连续定位的定位间隔
    locationOption.locationInterval = 2000;

    ///设置Android端的定位模式<br>
    ///可选值：<br>
    ///<li>[AMapLocationMode.Battery_Saving]</li>
    ///<li>[AMapLocationMode.Device_Sensors]</li>
    ///<li>[AMapLocationMode.Hight_Accuracy]</li>
    locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

    ///设置iOS端的定位最小更新距离<br>
    locationOption.distanceFilter = -1;

    /// 设置iOS端期望的定位精度
    /// 可选值：<br>
    /// <li>[DesiredAccuracy.Best] 最高精度</li>
    /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
    /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
    /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
    /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
    locationOption.desiredAccuracy = DesiredAccuracy.Best;

    ///设置iOS端是否允许系统暂停定位
    locationOption.pausesLocationUpdatesAutomatically = false;

    ///将定位参数设置给定位插件
    _locationPlugin.setLocationOption(locationOption);
  }

  startLocation() {
    _setLocationOption(); // 开始定位之前设置定位参数
    _locationPlugin.startLocation();
  }

  stopLocation() {
    _locationPlugin.stopLocation();
  }

  /// 申请定位权限
  _requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      startLocation();
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        startLocation();
        return true;
      } else {
        return false;
      }
    }
  }

  /// 获取iOS native的accuracyAuthorization类型
  _requestAccuracyAuthorization() async {
    AMapAccuracyAuthorization currentAccuracyAuthorization = await _locationPlugin.getSystemAccuracyAuthorization();
    if (currentAccuracyAuthorization == AMapAccuracyAuthorization.AMapAccuracyAuthorizationFullAccuracy) {
      print("精确定位类型");
    } else if (currentAccuracyAuthorization == AMapAccuracyAuthorization.AMapAccuracyAuthorizationReducedAccuracy) {
      print("模糊定位类型");
    } else {
      print("未知定位类型");
    }
  }
}
