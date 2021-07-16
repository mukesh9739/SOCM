import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pre_final/mqtt/state/MQTTAppState.dart';
import 'package:pre_final/mqtt/MQTTManager.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'dart:developer' as developer;

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
  int j = 2, max = 100;
  String t = '5000';

  void startCreatingDemoData() async {
    for (int i = 0; i < j; i++) {
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
          print(currentAppState.getReceivedText);
          setState(() {
            setChartData();
            j = j + 1;
            print('hi' + t);
            t = currentAppState.getReceivedText != ''
                ? currentAppState.getReceivedText.split(":")[1].split(";")[0]
                : t;
          });
        },
      );
    }
  }

  LineChartData data = LineChartData();
  void setChartData() {
    double xm = 1.0 * (j > 10 ? j - 10 : 0);
    data = LineChartData(
        // gridData: FlGridData(
        //   show: true,
        //   drawVerticalLine: true,
        //   getDrawingHorizontalLine: (value) {
        //     return FlLine(
        //       color: Color(0xff37434d),
        //       strokeWidth: 1,
        //     );
        //   },
        //   getDrawingVerticalLine: (value) {
        //     return FlLine(
        //       color: Color(0xff37434d),
        //       strokeWidth: 1,
        //     );
        //   },
        // ),
        // titlesData: FlTitlesData(
        //   show: true,
        //   bottomTitles: SideTitles(
        //     showTitles: true,
        //     reservedSize: 22,
        //     getTextStyles: (value) => TextStyle(
        //       color: Color(0xff67727d),
        //       fontWeight: FontWeight.bold,
        //       fontSize: 15,
        //     ),
        //     margin: 8,
        //   ),
        //   leftTitles: SideTitles(
        //     showTitles: true,
        //     getTextStyles: (value) => const TextStyle(
        //       color: Color(0xff67727d),
        //       fontWeight: FontWeight.bold,
        //       fontSize: 15,
        //     ),
        //     reservedSize: 28,
        //     margin: 12,
        //   ),
        // ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Color(0xff37434d), width: 1),
        ),
        minX: xm,
        minY: 0,
        maxY: 120000,
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

  @override
  void initState() {
    super.initState();
    setChartData();
    startCreatingDemoData();

    /*
    _hostTextController.addListener(_printLatestValue);
    _messageTextController.addListener(_printLatestValue);
    _topicTextController.addListener(_printLatestValue);
     */
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  /*
  _printLatestValue() {
    print("Second text field: ${_hostTextController.text}");
    print("Second text field: ${_messageTextController.text}");
    print("Second text field: ${_topicTextController.text}");
  }
   */

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    final Scaffold scaffold = Scaffold(body: _buildColumn());
    return scaffold;
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('MQTT'),
      backgroundColor: Colors.greenAccent,
    );
  }

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        _buildConnectionStateText(
            _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
        _buildEditableColumn(),
        //r_buildScrollableTextWith(currentAppState.getHistoryText),
        SizedBox(
          height: MediaQuery.of(context).size.height * .5,
          width: MediaQuery.of(context).size.width * .9,
          child: LineChart(data),
        ),
      ],
    );
  }

  Widget _buildEditableColumn() {
    _hostTextController.text = 'earth.informatik.uni-freiburg.de';
    _topicTextController.text = 'ubilab/test';
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
          // _buildTextFieldWith(_hostTextController, 'Enter broker address',
          //    currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          TextField(
              decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
            labelText: 'ubilab/test',
          )),
          // _buildTextFieldWith(
          //     _topicTextController,
          //     'Enter a topic to subscribe or listen',
          //     currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          //_buildPublishMessageRow(),
          const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          TextField(
              decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
            labelText: 'Cylinder 1',
          )),
          const SizedBox(height: 10),
          TextField(
              decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
            labelText: currentAppState.getReceivedText != ''
                ? currentAppState.getReceivedText.split(";")[1]
                : '',
          )),
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
  }

  void _disconnect() {
    manager.disconnect();
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
