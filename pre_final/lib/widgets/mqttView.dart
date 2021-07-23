import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pre_final/mqtt/state/MQTTAppState.dart';
import 'package:pre_final/mqtt/MQTTManager.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  int j = 2, max = 100, i = 0;
  String t = '100';

  void startCreatingDemoData() async {
    for (i = 0; i < j; i++) {
      if (i == 0) continue;
      await Future.delayed((Duration(seconds: 1))).then(
        (value) {
          Random random = Random();
          flspots.add(
            FlSpot(
              double.parse(i.toString()),
              1.0 * int.parse(t),
            ),
          );
          // if ((int.parse(t) * 1.0) < 300) {
          //   print("entered if");
          //   instantNofitication();
          // }
          print(currentAppState.getReceivedText);
          setState(() {
            setChartData();
            j = j + 1;
            print('hi' + t);
            //if for checking valueselected
            t = currentAppState.getReceivedText != ''
                ? currentAppState.getReceivedText.split(":")[1].split(";")[0]
                : t;
          });
        },
      );
    }
  }

  Future instantNofitication() async {
    print("notif");
    var android = AndroidNotificationDetails("id", "channel", "description");

    var ios = IOSNotificationDetails();

    var platform = new NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.show(
        0, "Demo instant notification", "Tap to do something", platform,
        payload: "Welcome to demo app");
  }

  LineChartData data = LineChartData();
  void setChartData() {
    double xm = 1.0 * (j > 10 ? j - 10 : 0);
    data = LineChartData(
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Color(0xff37434d), width: 1),
        ),
        minX: xm,
        minY: 0,
        maxY: 300,
        clipData: FlClipData.all(),
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(y: 80, color: Colors.green, strokeWidth: 5)
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

  List<FlSpot> flspots = [
    FlSpot(0, 0),
  ];

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    setChartData();
    startCreatingDemoData();
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

  bool conntoserver = false;

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        _buildConnectionStateText(
            _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
        _buildEditableColumn(),
        Visibility(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .45,
            width: MediaQuery.of(context).size.width * .9,
            child: LineChart(data),
          ),
          visible: conntoserver,
        ),
      ],
    );
  }

  var _topiclist = [];

  Widget _buildEditableColumn() {
    _hostTextController.text = 'earth.informatik.uni-freiburg.de';
    _topicTextController.text = 'ubilab/test'; //valueChoose.toString();
    // currentAppState.getReceivedText != ''
    //     ? (int.parse(currentAppState.getReceivedText
    //                 .split(":")[1]
    //                 .split(";")[0]) <
    //             300
    //         ? instantNofitication()
    //         : '')
    //     : '';
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
            items: _topiclist.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Text(dropDownStringItem),
              );
            }).toList(),
            onChanged: (valueSelectedByUser) {
              setState(() {
                valueChoose = valueSelectedByUser;
              });
            },
            value: valueChoose,
          ),
          const SizedBox(height: 10),
          //_buildPublishMessageRow(),
          const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          Visibility(
            child: TextField(
                decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
              labelText: currentAppState.getReceivedText != ''
                  ? currentAppState.getReceivedText.split(";")[1]
                  : '',
            )),
            visible: conntoserver,
          ),

          const SizedBox(height: 20)
        ],
      ),
    );
  }

  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildTextFieldWith(_messageTextController, 'Enter a message',
              currentAppState.getAppConnectionState),
        ),
        _buildSendButtonFrom(currentAppState.getAppConnectionState)
      ],
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

  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if (controller == _messageTextController &&
        state == MQTTAppConnectionState.connected) {
      shouldEnable = true;
    } else if ((controller == _hostTextController &&
            state == MQTTAppConnectionState.disconnected) ||
        (controller == _topicTextController &&
            state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
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

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    // ignore: deprecated_member_use
    return RaisedButton(
      color: Colors.green,
      child: const Text('Send'),
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              _publishMessage(_messageTextController.text);
            }
          : null, //
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
    // ignore: flutter_style_todos
    // TODO: Use UUID
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
    });
    currentAppState.setReceivedText('');
  }

  void _publishMessage(String text) {
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    final String message = osPrefix + ' says: ' + text;
    manager.publish(message);
    _messageTextController.clear();
  }
}
