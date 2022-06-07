import 'package:appool/dados.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'controles.dart';

class Lateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection connection;
  int _deviceState;

  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };
  bool get isConnected => connection != null && connection.isConnected;

  void exibirtelasair() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("SAIR"),
            content: Text("Você tem certeza que deseja sair?"),
            backgroundColor: Colors.white,
            actions: <Widget>[
              RaisedButton(
                color: Colors.red,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              RaisedButton(
                color: Colors.red,
                child: Text(
                  "Sim",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  showToast('saindo');
                  SystemNavigator.pop();
                },
              )
            ],
          );
        });
  }

  void showToast(String mensagem) {
    Fluttertoast.showToast(
        msg: mensagem,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black);
  }

  @override
  void initState() {
    super.initState();
 
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0;
    enableBluetooth();

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  Future<void> enableBluetooth() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _devicesList = devices;
    });
  }

  void _obtconnect() {
    if (_device == null) {
      showToast('Nenhum dispositivo selecionado');
    } else {
      _connect();
    }
  }

  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      showToast('Nenhum dispositivo selecionado');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Dispositivo Conectado');
          showToast('Dispositivo Conectado');
          connection = _connection;

          setState(() {
            print('teste');
            _connected = true;
          });
        }).catchError((error) {
          showToast('Nao Foi Possivel Conectar');
          print('Nao foi possivel conectar');
          print(error);
        });
        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  void controlar() async {
        Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => AppPool(connection)),);
        
  
  }

  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    connection.close();
    showToast('Dispositivo Desconectado');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  void _registro() {
    Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => Dados()),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('SELECIONE UM DISPOSITIVO'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.blue[800],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0))),
            height: 180,
            width: double.infinity,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "MENU INICIAL",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(10, 30, 10, 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            ' Bluetooth',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        Transform.scale(
                            scale: 1.2,
                            child: Switch(
                              value: _bluetoothState.isEnabled,
                              activeColor: Colors.white,
                              onChanged: (bool value) {
                                future() async {
                                  if (value) {
                                    await FlutterBluetoothSerial.instance
                                        .requestEnable();
                                  } else {
                                    await FlutterBluetoothSerial.instance
                                        .requestDisable();
                                  }

                                  await getPairedDevices();
                                  _isButtonUnavailable = false;

                                  if (_connected) {
                                    _disconnect();
                                  }
                                }

                                future().then((_) {
                                  setState(() {});
                                });
                              },
                            ))
                      ],
                    ),
                  ),
                ]),
          ),
          Visibility(
            visible: _isButtonUnavailable &&
                _bluetoothState == BluetoothState.STATE_ON,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 75,
                margin: EdgeInsets.all(10),
                child: RaisedButton.icon(
                  onPressed: () {
                    FlutterBluetoothSerial.instance.openSettings();
                  },
                  icon: Icon(Icons.settings),
                  label: Text(
                    'Configuração',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                height: 75,
                child: RaisedButton.icon(
                  icon: Icon(Icons.bluetooth),
                  onPressed: _isButtonUnavailable
                      ? null
                      : _connected
                          ? _disconnect
                          : _obtconnect,
                  label: Text(
                    _connected ? 'Desconectar' : 'Conectar',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                height: 75,
                child: RaisedButton.icon(
                  icon: Icon(Icons.analytics),
                  onPressed: _registro,
                  label: Text(
                    'Registros',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                height: 75,
                child: RaisedButton.icon(
                  icon: Icon(Icons.dashboard),
                  onPressed: _connected ? controlar : null,
                  label: Text(
                    "Controles",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                height: 75,
                child: RaisedButton.icon(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    exibirtelasair();
                  },
                  label: Text(
                    'Sair',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
          Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Colors.blue[800],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(25)),
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Text(
                        "DISPOSITIVOS PAREADOS",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white24,
                          ),
                          child: DropdownButton(
                            hint: new Text("Selecionar"),
                            style: TextStyle(fontSize: 24, color: Colors.white),
                            items: _getDeviceItems(),
                            dropdownColor: Colors.grey,
                            iconSize: 45,
                            iconEnabledColor: Colors.white,
                            isExpanded: true,
                            underline: SizedBox(),
                            onChanged: (value) =>
                                setState(() => _device = value),
                            value: _devicesList.isNotEmpty ? _device : null,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: new BorderSide(
                            color: _deviceState == 0
                                ? colors['neutralBorderColor']
                                : _deviceState == 1
                                    ? colors['onBorderColor']
                                    : colors['offBorderColor'],
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        elevation: _deviceState == 0 ? 4 : 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
