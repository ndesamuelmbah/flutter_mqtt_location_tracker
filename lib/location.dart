import 'dart:convert';
import 'dart:io';
import 'dart:math' show cos, asin, sqrt;
//import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:location/location.dart';
// import 'package:http/io_client.dart';
// //import 'package:location/location.dart' as loc;
// import 'package:geocoding/geocoding.dart';
// import 'package:logging/logging.dart';

class Addresses {
  // static Logger logger = Logger('enterUserName');

  // static IOClient https() {
  //   HttpClient client = HttpClient();
  //   client.badCertificateCallback =
  //       (X509Certificate cert, String host, int port) => true;
  //   return IOClient(client);
  // }

  // static http.Client httpsClient() {
  //   return http.Client();
  // }

  static const String geolocationStr = 'geolocation';
  static const String locationStr = 'location';

  // static Map<String, dynamic> getApiRes(http.Response response) {
  //   return response.statusCode == 200
  //       ? jsonDecode(utf8.decode(response.bodyBytes))
  //       : null;
  // }

  static bool areLocationPermissionsAllowedGeolocation(
      geolocator.LocationPermission permission) {
    return permission == geolocator.LocationPermission.whileInUse ||
        permission == geolocator.LocationPermission.always;
  }

  // static bool areLocationPermissionsAllowedLocation(
  //     loc.PermissionStatus permission) {
  //   return permission == loc.PermissionStatus.granted ||
  //       permission == loc.PermissionStatus.grantedLimited;
  // }

  // static Future<loc.LocationData?> getLocationCoordinatesLocation() async {
  //   loc.Location location = loc.Location();
  //   loc.PermissionStatus permissionStatus;
  //   loc.LocationData locationData;

  //   try {
  //     locationData = await location.getLocation();
  //     return locationData;
  //   } catch (e) {
  //     permissionStatus = await location.hasPermission();
  //     if (!areLocationPermissionsAllowedLocation(permissionStatus)) {
  //       if (permissionStatus == loc.PermissionStatus.deniedForever) {
  //         return null;
  //       } else {
  //         permissionStatus = await location.requestPermission();
  //         if (!areLocationPermissionsAllowedLocation(permissionStatus)) {
  //           return null;
  //         }
  //       }
  //     }
  //     locationData = await location.getLocation();
  //     return locationData;
  //   }
  // }

  // static Future<String?> getLocationPermissionsLocation() async {
  //   loc.Location location = loc.Location();
  //   try {
  //     bool serviceEnabled = await location.serviceEnabled();
  //     if (!serviceEnabled) {
  //       serviceEnabled = await location.requestService();
  //       if (!serviceEnabled) {
  //         return null;
  //       }
  //     }
  //     loc.PermissionStatus permissionStatus = await location.hasPermission();
  //     while (permissionStatus == loc.PermissionStatus.denied) {
  //       permissionStatus = await location.requestPermission();
  //     }
  //     return [loc.PermissionStatus.denied, loc.PermissionStatus.deniedForever]
  //             .contains(permissionStatus)
  //         ? null
  //         : locationStr;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  static Future<String?> getLocationPermissionsGeolocation(
      {bool requestIfNotGranted = true}) async {
    geolocator.LocationPermission permission;
    bool serviceEnabled =
        await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      //return getLocationPermissionsLocation();
      return null;
    }
    permission = await geolocator.Geolocator.checkPermission();
    if (requestIfNotGranted &&
        permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
    }
    // while (permission == LocationPermission.denied) {
    //   permission = await geolocator.Geolocator.requestPermission();
    // }
    return permission == geolocator.LocationPermission.denied ||
            permission == geolocator.LocationPermission.deniedForever
        ? null //getLocationPermissionsLocation()
        : Future.value(geolocationStr);
  }

  // static Future<Map<String, dynamic>?> getBackendAddressFromLatLng(
  //     {required double lat, required double lng}) async {
  //   String url =
  //       'https://dukafoodsapi-frymsljk7q-ew.a.run.app/extract_address_from_lat_long';
  //   Map<String, String> params = {'lng': lng.toString(), 'lat': lat.toString()};
  //   Uri uri = Uri.parse(url);
  //   print('Reached Here with lat = $lat, lng = $lng');
  //   http.Response response =
  //       await httpsClient().post(uri, body: params, headers: {
  //     'accept': 'application/json',
  //     'header': "3ab3852d-f8e9-4f2d-8cbd-24c5e1572765",
  //     'Content-Type': 'application/x-www-form-urlencoded'
  //   }).catchError((e, stackTrace) {
  //     print(e);
  //     print(stackTrace);
  //     logger.severe(e, stackTrace);
  //   });
  //   print(response.body);
  //   print(response.statusCode);
  //   print(response.toString());
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> addressMap = getApiRes(response);
  //     addressMap['lat'] = lat;
  //     addressMap['lng'] = lng;
  //     return addressMap;
  //   } else {
  //     return null;
  //   }
  // }

  static double distanceBetweenTwoCords(
      double lat1, double lng1, double lat2, double lng2,
      {bool inKm = true}) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
    double distInKm = 12742 * asin(sqrt(a));
    if (inKm) {
      return distInKm;
    }
    return distInKm * 0.621371;
  }

  // static Future<Map<String, dynamic>?> getAddressFromBackend(
  //     Function(String?) callBack) async {
  //   Position? geoposition;
  //   final String? addressType = await getLocationPermissionsGeolocation();
  //   callBack(addressType);
  //   if (addressType == geolocationStr) {
  //     try {
  //       geoposition = await getCurrentUsersCoordinates();
  //     } catch (e) {
  //       geoposition = await geolocator.Geolocator.getLastKnownPosition();
  //     }
  //     if (geoposition != null) {
  //       Map<String, dynamic>? addressData = await getBackendAddressFromLatLng(
  //           lat: geoposition.latitude, lng: geoposition.longitude);

  //       if (addressData != null) {
  //         return addressData;
  //       } else {
  //         Map<String, dynamic>? placemarkAddress =
  //             await getAddressFromPlacemark(
  //                 latitude: geoposition.latitude,
  //                 longitude: geoposition.longitude);
  //         return placemarkAddress;
  //       }
  //     } else {
  //       return null;
  //     }
  //   }
  //   // else if (addressType == locationStr) {
  //   //   loc.LocationData? locationData = await getLocationCoordinatesLocation();
  //   //   if (locationData != null) {
  //   //     Map<String, dynamic>? address = await getBackendAddressFromLatLng(
  //   //         lat: locationData.latitude!, lng: locationData.longitude!);
  //   //     if (address != null) {
  //   //       return address;
  //   //     } else {
  //   //       Map<String, dynamic>? placemarkAddress =
  //   //           await getAddressFromPlacemark(
  //   //               latitude: locationData.latitude!,
  //   //               longitude: locationData.longitude!);
  //   //       return placemarkAddress;
  //   //     }
  //   //   } else {
  //   //     return null;
  //   //   }
  //   // }
  //   else {
  //     return null;
  //   }
  // }

  // static Future<List<Location>> getLatLngFromCountry(
  //     String formatedAddress) async {
  //   return await locationFromAddress(formatedAddress,
  //       localeIdentifier: "en_US");
  // }

  // static Future<Map<String, dynamic>?>? getCurrentAddressMap() async {
  //   Position? geoposition;
  //   final String? addressType = await getLocationPermissionsGeolocation();
  //   if (addressType == geolocationStr) {
  //     try {
  //       geoposition = await getCurrentUsersCoordinates();
  //     } catch (e) {
  //       geoposition = await geolocator.Geolocator.getLastKnownPosition();
  //     }
  //     if (geoposition != null) {
  //       Placemark? placemarkAddress = await getGeocoderAddressFromLatLng(
  //           lat: geoposition.latitude, lng: geoposition.longitude);
  //       return cleanedPlacemark(
  //           placemarkAddress, geoposition.latitude, geoposition.longitude);
  //     } else {
  //       return null;
  //     }
  //   } else {
  //     return null;
  //   }
  //   // else if (addressType == locationStr) {
  //   //   loc.LocationData? locationData = await getLocationCoordinatesLocation();
  //   //   if (locationData != null) {
  //   //     Placemark? placemarkAddress = await getGeocoderAddressFromLatLng(
  //   //         lat: locationData.latitude, lng: locationData.longitude);
  //   //     return cleanedPlacemark(
  //   //         placemarkAddress, locationData.latitude, locationData.longitude);
  //   //   } else {
  //   //     return null;
  //   //   }
  //   // } else {
  //   //   return null;
  //   // }
  // }

  // static Future<Map<String, dynamic>?> getAddressFromPlacemark(
  //     {required double latitude, required double longitude}) async {
  //   Placemark? geocoderAddress =
  //       await getGeocoderAddressFromLatLng(lat: latitude, lng: longitude);
  //   Map<String, dynamic>? cityStateCountryCode =
  //       getCityAndStateFromGeocoderAddress(geocoderAddress,
  //           lat: latitude, lng: longitude);
  //   if (cityStateCountryCode == null) {
  //     return null;
  //   } else {
  //     cityStateCountryCode['lng'] = longitude;
  //     cityStateCountryCode['lat'] = latitude;
  //     int? addressId = await saveANewAddress(addressData: cityStateCountryCode);
  //     cityStateCountryCode['address_id'] = addressId;
  //     return cityStateCountryCode;
  //   }
  // }

  // static Future<int?> saveANewAddress(
  //     {required Map<String, dynamic> addressData}) async {
  //   String url = 'https://www.peervendors.com/save_a_new_address/';
  //   Map<String, String> params =
  //       addressData.map((key, value) => MapEntry(key, value.toString()));
  //   Uri uri = Uri.parse(url);
  //   http.Response response =
  //       await httpsClient().post(uri, body: params, headers: {
  //     'accept': 'application/json',
  //     'header': "38ea57ca-f1a9-462c-a280-4eedfab0328b",
  //     'Content-Type': 'application/x-www-form-urlencoded'
  //   });
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> addressIdMap = getApiRes(response);
  //     return addressIdMap['address_id'];
  //   } else {
  //     return null;
  //   }
  // }

  // static Map<String, dynamic> cleanedPlacemark(
  //     Placemark? placemark, double? lat, double? lng) {
  //   if (placemark == null) {
  //     return {};
  //   }
  //   Map<String, dynamic> lastAdInfo = Map.from(placemark.toJson())
  //     ..removeWhere((k, v) => v == null || v.isEmpty);
  //   if (lat != null) {
  //     lastAdInfo['lat'] = lat;
  //     lastAdInfo['lng'] = lng;
  //   }
  //   return lastAdInfo;
  // }

  static String getKeyFromAddressMap(
      Map<String, dynamic> address, String keys, String keyType) {
    for (String key in keys.split(',')) {
      if (address.containsKey(key)) {
        return address[key];
      }
    }
    if (address.containsKey('name')) {
      List<String> addressParts = address['name'].split(', ');
      return keyType == 'city' ? addressParts.first : addressParts.last;
    }
    if (address.containsKey('street')) {
      return address['street'].split(', ').last;
    }
    return keyType;
  }

  // static Map<String, dynamic>? getCityAndStateFromGeocoderAddress(
  //     Placemark? geocoderAddress,
  //     {required double lat,
  //     required double lng}) {
  //   if (geocoderAddress != null) {
  //     Map<String, dynamic> rawAddressMap =
  //         cleanedPlacemark(geocoderAddress, lat, lng);
  //     Map<String, dynamic> addressData = <String, dynamic>{};
  //     addressData['state'] = getKeyFromAddressMap(
  //         rawAddressMap,
  //         'locality,subLocality,subAdministrativeArea,thoroughfare,subThoroughfare,administrativeArea',
  //         'city');
  //     addressData['city'] = getKeyFromAddressMap(
  //         rawAddressMap,
  //         'administrativeArea,subAdministrativeArea,locality,subLocality',
  //         'state');
  //     addressData['country_code'] =
  //         geocoderAddress.isoCountryCode?.toUpperCase();
  //     return addressData;
  //   } else {
  //     return null;
  //   }
  // }

  static void openLocSettings() {
    try {
      geolocator.Geolocator.openLocationSettings();
    } catch (e) {
      openAppSettings();
    }
  }

  static void openAppSettings() {
    openAppSettings();
  }

  static Future<geolocator.Position?> getUsersCurrentAddress(
      {int minTimeToWaitInSeconds = 15, bool isInternal = false}) async {
    if (isInternal) {
      return await getAddress();
    } else {
      bool serviceEnabled;
      geolocator.LocationPermission permission;
      serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }
      permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
        if (permission == geolocator.LocationPermission.deniedForever ||
            permission == geolocator.LocationPermission.denied) {
          return null;
        } else {
          return await getAddress();
        }
      } else {
        return await getAddress();
      }
    }
  }

  // static Future<Position> getCurrentUsersCoordinates() async {
  //   return await geolocator.Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  // }

  static Future<geolocator.Position?> getAddress() async {
    geolocator.Position? geoposition =
        await geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.high);

    return geoposition;
  }

  // static Future<Placemark?> getGeocoderAddressFromLatLng(
  //     {required double? lat, required double? lng}) async {
  //   if (lat == null || lng == null) {
  //     return null;
  //   } else {
  //     List<Placemark>? addresses =
  //         await placemarkFromCoordinates(lat, lng, localeIdentifier: 'en-US');
  //     return addresses.isEmpty == true ? null : addresses.first;
  //   }
  // }
}
