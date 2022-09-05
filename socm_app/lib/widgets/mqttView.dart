import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socm_app/mqtt/state/MQTTAppState.dart';
import 'package:socm_app/mqtt/MQTTManager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MQTTView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  late MQTTAppState currentAppState;
  late MQTTManager manager;
  int j = 2, i = 0;
  String t = '10', t1 = '0';
  bool notifcheck = true;
  Position currentposition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime(0),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool conntoserver = false;
  var activelist = [];
  var alivelist = [''];
  String? valueChoose = '';
  String? notifcylinder = '';
  var locchoose = '';
  bool display = false;
  List<FlSpot> flspots = [
    FlSpot(0, 0),
  ];
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  LineChartData data = LineChartData();

  @override
  void initState() {
    super.initState();
    setChartData();
    startCreatingDemoData();
    handleTimeout();
    notifinitialize();
  }

  Future notifinitialize() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("ic_launcher");
    IOSInitializationSettings iosInitializationSettings =
        IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings,
            iOS: iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    final Scaffold scaffold = Scaffold(
        appBar: AppBar(
          title: const Text('SOCM'),
          backgroundColor: Colors.greenAccent,
        ),
        body: _buildColumn());
    return scaffold;
  }

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        _buildConnectionStateText(
            _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
        _buildEditableColumn(),
        Visibility(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .41,
            width: MediaQuery.of(context).size.width * .9,
            child: LineChart(data),
          ),
          visible: display && valueChoose != '' && conntoserver,
        ),
      ],
    );
  }

  Widget _buildEditableColumn() {
    _hostTextController.text = 'earth.informatik.uni-freiburg.de';
    _topicTextController.text = 'ubilab/test';
    setState(() {
      var historyText = currentAppState.getHistoryText.split("\n");
      if (currentAppState.getReceivedText != '') {
        if (activelist.isEmpty) {
          activelist.add(currentAppState.getReceivedText.split(";")[1]);
        } else {
          int check = 0;
          for (int i = 0; i < activelist.length; i++) {
            if (activelist[i].toString() ==
                currentAppState.getReceivedText.split(";")[1]) {
              check = 1;
            }
          }
          if (check != 1) {
            activelist.add(currentAppState.getReceivedText.split(";")[1]);
            check = 0;
          }
        }
        int buffer = historyText.length - (activelist.length * 5);
        if ((historyText.length > (activelist.length * 5)) && buffer > 0) {
          int f = 0;
          for (int count = 0; count < activelist.length; count++) {
            f = 0;
            for (int i = buffer; i < historyText.length; i++) {
              if (historyText[i].toString() != '') {
                if (historyText[i].split(";")[1].toString() ==
                    activelist[count].toString()) {
                  f = f + 1;
                }
              }
            }
            if (f >= 3) {
              if (alivelist.length > 0) {
                int check = 0;
                for (int i = 0; i < alivelist.length; i++) {
                  if (alivelist[i].toString() == activelist[count].toString()) {
                    check = 1;
                  }
                }
                if (check != 1) {
                  alivelist.add(activelist[count].toString());
                  check = 0;
                }
              }
            } else {
              if (alivelist.contains(activelist[count].toString()) == true) {
                alivelist.remove(activelist[count].toString());
              }
            }
          }
        }
      }
      if (valueChoose != '') {
        display = true;
      }
    });

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          TextField(
              decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
            labelText: 'earth.informatik.uni-freiburg.de',
          )),
          const SizedBox(height: 10),
          DropdownButton<String>(
            items: alivelist.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Text(dropDownStringItem),
              );
            }).toList(),
            onChanged: (valueSelectedByUser) {
              setState(() {
                valueChoose = valueSelectedByUser;
                i = 0;
                j = 2;
                flspots.clear();
              });
            },
            value: valueChoose,
          ),
          // const SizedBox(height: 5),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          Visibility(
            child: TextField(
                decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
              labelText: "Cylinder : " + valueChoose.toString(),
            )),
            visible: display && valueChoose != '',
          ),
          Visibility(
            child: Column(
              children: [
                TextField(
                    decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      left: 0, bottom: 0, top: 0, right: 0),
                  labelText: "Cylinder Location : " + locchoose.toString(),
                )),
                TextButton(
                    onPressed: () {
                      _launchURL();
                    },
                    child: Text('Locate me'))
              ],
            ),
            visible: display && valueChoose != '',
          ),
          //const SizedBox(height: 20)
        ],
      ),
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.deepOrangeAccent,
              child: Text(status, textAlign: TextAlign.center)),
        ),
      ],
    );
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: Colors.lightBlueAccent,
            child: const Text('Connect'),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null, //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: Colors.redAccent,
            child: const Text('Disconnect'),
            onPressed: state == MQTTAppConnectionState.connected
                ? _disconnect
                : null, //
          ),
        ),
      ],
    );
  }

  // Utility functions
  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  void _configureAndConnect() {
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    manager = MQTTManager(
        host: _hostTextController.text,
        topic: _topicTextController.text,
        identifier: osPrefix,
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
    setState(() {
      conntoserver = true;
    });
    flspots.clear();
  }

  void _disconnect() {
    manager.disconnect();
    setState(() {
      conntoserver = false;
      i = 0;
      j = 2;
      flspots.clear();
      valueChoose = '';
      notifcheck = true;
    });
    currentAppState.setReceivedText('');
  }

  void _launchURL() async =>
      launch('https://www.google.com/maps/search/?api=1&query=' +
          locchoose.toString());

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      setState(() {
        currentposition = position;
        double distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            double.parse(currentAppState.getReceivedText
                .split(";")[2]
                .split(",")[0]
                .toString()),
            double.parse(currentAppState.getReceivedText
                .split(";")[2]
                .split(",")[1]
                .toString()));
        print(distanceInMeters);
        if (distanceInMeters < 100) {
          instantNofitication(
              currentAppState.getReceivedText.split(";")[1].toString());
          notifcheck = false;
          handleTimeout();
        } else {
          notifcheck = false;
          handleTimeoutloc();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void startCreatingDemoData() async {
    for (i = 0; i < j; i++) {
      if (i == 0) continue;
      await Future.delayed((Duration(seconds: 1))).then(
        (value) {
          flspots.add(
            FlSpot(
              double.parse(i.toString()),
              ((1.0 * int.parse(t) - 152.0) / 3.4),
            ),
          );
          setState(() {
            setChartData();
            j = j + 1;
            print('hi' + t);
            t = currentAppState.getReceivedText != ''
                ? currentAppState.getReceivedText.split(";")[1].toString() ==
                        valueChoose.toString()
                    ? currentAppState.getReceivedText.split(";")[0]
                    : t
                : t;
            t1 = currentAppState.getReceivedText != ''
                ? currentAppState.getReceivedText.split(";")[0]
                : t1;
            if (conntoserver &&
                (((1.0 * int.parse(t1) - 152.0) / 3.4) < 5) &&
                currentAppState.getReceivedText != '' &&
                alivelist.length > 1 &&
                notifcheck) {
              _determinePosition();
            }
            if (conntoserver && alivelist.length > 1) {
              locchoose = currentAppState.getReceivedText != ''
                  ? currentAppState.getReceivedText.split(";")[1].toString() ==
                          valueChoose.toString()
                      ? currentAppState.getReceivedText.split(";")[2].toString()
                      : locchoose
                  : locchoose;
            }
          });
        },
      );
    }
  }

  void handleTimeoutloc() async {
    await Future.delayed((Duration(seconds: 120))).then(
      (value) {
        notifcheck = true;
      },
    );
  }

  void handleTimeout() async {
    await Future.delayed((Duration(seconds: 4))).then(
      (value) {
        notifcheck = true;
      },
    );
  }

  Future instantNofitication(String a) async {
    var android = AndroidNotificationDetails("id", "channel", "description");
    var ios = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: ios);
    await _flutterLocalNotificationsPlugin.show(
        0, "Cylinder : " + a, "below threshold ", platform,
        payload: "Welcome to demo app");
  }

  void setChartData() {
    double xm = 1.0 * (j > 10 ? j - 10 : 0);
    data = LineChartData(
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Color(0xff37434d), width: 1),
        ),
        minX: xm,
        minY: 0,
        maxY: 20,
        clipData: FlClipData.all(),
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(y: 5, color: Colors.green, strokeWidth: 5)
        ]),
        lineBarsData: [
          LineChartBarData(
              spots: flspots,
              isCurved: true,
              colors: gradientColors,
              barWidth: 1,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: false,
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
              )),
        ]);
  }
}
