// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:flutter/material.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:permission_handler/permission_handler.dart';

double calcDistance(double lat1, double lng1, double lat2, double lng2) {
  if (lat1 < 0 || lng1 < 0) {
    return 0;
  }
  double rad(double d) => d * pi / 180.0;

  double radLat1 = rad(lat1);
  double radLat2 = rad(lat2);
  double a = radLat1 - radLat2;
  double b = rad(lng1) - rad(lng2);
  double s = 2 * asin(sqrt(pow(sin(a / 2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(b / 2), 2)));
  return (s * 6378.137 * 10000).round() / 10000;
}

class AMap {
  static getInstance() => _instance;
  static final _instance = AMap._internal();
  factory AMap() => getInstance();
  AMap._internal() {
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    _requestLocationPermission(); // 动态申请定位权限
    AMapFlutterLocation.setApiKey("0f85c261d48608ece2b180d7778d6861", "ios ApiKey");
    // iOS 获取native精度类型
    if (Platform.isIOS) {
      _requestAccuracyAuthorization();
    }
    // 注册定位结果监听
    _locationListener = _locationPlugin.onLocationChanged().listen((Map<String, Object> result) {
      location = result;
      stopLocation();
      print(location);
    });
    startLocation();
  }

  StreamSubscription<Map<String, Object>>? _locationListener;
  final _locationPlugin = AMapFlutterLocation();
  Map<String, dynamic> location = {};
  var a = const AMapWidget(
      // onMapCreated: onMapCreated,
      );

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
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
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

class ConstConfig {
  /// 配置您申请的apikey，在此处配置之后，可以在初始化[AMapWidget]时，通过`apiKey`属性设置
  /// 注意：使用[AMapWidget]的`apiKey`属性设置的key的优先级高于通过Native配置key的优先级，
  /// 使用[AMapWidget]的`apiKey`属性配置后Native配置的key将失效，请根据实际情况选择使用
  static const AMapApiKey amapApiKeys = AMapApiKey(androidKey: '0f85c261d48608ece2b180d7778d6861', iosKey: '您申请的iOS平台的key');

  /// 高德隐私合规声明，这里只是示例，实际使用中请按照实际参数设置[AMapPrivacyStatement]的'hasContains''hasShow''hasAgree'这三个参数
  /// 注意：[AMapPrivacyStatement]的'hasContains''hasShow''hasAgree'这三个参数中有一个为false，高德SDK均不会工作，会造成地图白屏等现象
  /// 高德开发者合规指南请参考：https://lbs.amap.com/agreement/compliance
  /// 高德SDK合规使用方案请参考：https://lbs.amap.com/news/sdkhgsy
  static const AMapPrivacyStatement amapPrivacyStatement = AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true);
}

class SiluMap extends StatefulWidget {
  const SiluMap({Key? key}) : super(key: key);

  @override
  State<SiluMap> createState() => _SiluMapState();
}

class _SiluMapState extends State<SiluMap> {
  @override
  void initState() {
    super.initState();
    Permission.location.request();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AMap().a,
    );
  }

  /// 获取审图号
  void getApprovalNumber() async {
  }
}
