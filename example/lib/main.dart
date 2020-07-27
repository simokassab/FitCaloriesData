import 'package:flutter/material.dart';
import 'dart:async';
import 'package:health/health.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _healthKitOutput;
  double total = 0.0;
  double totall = 0.0;
  var _healthDataList = List<HealthDataPoint>();
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    //useGoogleApi();
    //  googlesign();
  }

  getCalories() async {
    if (Platform.isAndroid) {
      totall = 0.0;
      total = 0.0;
      print('android');
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/fitness.activity.read',
        ],
      );
      try {
        GoogleSignInAccount account = await _googleSignIn.signIn();
        final authentication = await account.authentication;
        print(authentication.accessToken);
        _setHeaders() => {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ' + authentication.accessToken
            };
        var endtime = new DateTime.now().millisecondsSinceEpoch;
        DateTime now = new DateTime.now();
        DateTime date = new DateTime(now.year, now.month, now.day);
        print(now.toString() + " " + date.toString());
        var stime = date.millisecondsSinceEpoch;
        print(endtime.toString() + "--" + stime.toString());
        Uri url = Uri.tryParse(
            "https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate");
        var body =
            '{        "aggregateBy" : [{           "dataSourceId": "derived:com.google.calories.expended:com.google.android.gms:from_activities"       }],        "startTimeMillis": ' +
                stime.toString() +
                ',     "endTimeMillis": ' +
                endtime.toString() +
                '} ';
        print(body);
        // final headers = {'Authorization': 'Bearer ' + authentication.accessToken};

        var res = await http.post(url, body: body, headers: _setHeaders());
        var bod = json.decode(res.body);
        print(bod['bucket'][0]['dataset'][0]['point']);
        if (bod['bucket'][0]['dataset'][0]['point'].isEmpty) {
          print("empty");
          total = 0.0;
        } else {
          for (var fp in bod['bucket'][0]['dataset'][0]['point']) {
            totall = totall + fp['value'][0]['fpVal'];
          }
        }
        setState(() {
          total = totall;
        });

        print(total);
        // print(bod['bucket'][0]['dataset'][0]['point'][0]['value'][0]['fpVal']);
        // for(int i = 0; i< bod['bucket'][0]['dataset'][0]['point'][0]);
        //dsdf
      } catch (error) {
        print(error);
      }
    } else if (Platform.isIOS) {
      total = 0.0;
      _healthDataList = [];
      DateTime dateToday = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      print(dateToday);
      DateTime startDate = DateTime.utc(2001, 01, 01);
      DateTime endDate = DateTime.now();

      Future.delayed(Duration(seconds: 2), () async {
        _isAuthorized = await Health.requestAuthorization();

        if (_isAuthorized) {
          print('Authorized');

          bool weightAvailable =
              Health.isDataTypeAvailable(HealthDataType.WEIGHT);
          print("is WEIGHT data type available?: $weightAvailable");

          /// Specify the wished data types
          List<HealthDataType> types = [
            // HealthDataType.WEIGHT,
            // HealthDataType.HEIGHT,
            // HealthDataType.STEPS,
            // HealthDataType.BODY_MASS_INDEX,
            // HealthDataType.WAIST_CIRCUMFERENCE,
            // HealthDataType.BODY_FAT_PERCENTAGE,
            HealthDataType.ACTIVE_ENERGY_BURNED,
            // HealthDataType.BASAL_ENERGY_BURNED,
            // HealthDataType.HEART_RATE,
            // HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
            // HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
            // HealthDataType.RESTING_HEART_RATE,
            // HealthDataType.BLOOD_GLUCOSE,
            // HealthDataType.BLOOD_OXYGEN,
          ];

          //  for (HealthDataType type in types) {
          /// Calls to 'Health.getHealthDataFromType'
          /// must be wrapped in a try catch block.b
          try {
            List<HealthDataPoint> healthData;
            healthData = await Health.getHealthDataFromType(
                dateToday, endDate, HealthDataType.ACTIVE_ENERGY_BURNED);
            _healthDataList.addAll(healthData);
          } catch (exception) {
            print(exception.toString());
          }
          //}
          var x;
          total = 0.0;

          /// Print the results
          for (x in _healthDataList) {
            setState(() {
              total = total + x.value;
            });

            print("Data point: $x");
          }
          print(total);

          /// Update the UI to display the results
          setState(() {});
        } else {
          print('Not authorized');
        }
      });

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      getCalories();
                    },
                    child: Text("Get Data"),
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                  ),
                  Text("$total")
                ],
              ),
            ),
          )),
    );
  }
}
