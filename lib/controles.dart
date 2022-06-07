import 'dart:async';
import 'dart:typed_data';

import 'package:appool/Model/pH.dart';
import 'package:appool/utils/PhHelpers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'lateral.dart';
import 'dart:convert';
import 'dart:math';

// ignore: must_be_immutable
class AppPool extends StatefulWidget {
  var recteste;
  AppPool(this.recteste);

  @override
  _AppPoolState createState() => _AppPoolState();
}

class _AppPoolState extends State<AppPool> {
  String ph = "- . - -";
  bool motor = false;
  bool automatico = false;
  int dosarcloro = 0;
  bool isDisconnecting = false;
  bool get isConnected => blueconnect != null && blueconnect.isConnected;
  String _messageBuffer = '';
  String recebido;
  PhHelpers _db = PhHelpers();
  DateTime now;
  String agora;
  String agoraux = DateFormat('kk:mm').format(DateTime.now());

  var blueconnect;

  @override
  void initState() {
    
    blueconnect = widget.recteste;
    print(blueconnect);
    super.initState();
    
    blueconnect.input.listen(_onDataReceived).onDone(() {
      if (isDisconnecting) {

        print('Desconectando');
        showToast('Desconectando');
      } else {
        showToast('Dispositivo Desconectou');
        print('Dispositivo desconectou');
      }
      if (this.mounted) {
        setState(() {});
      }
    });
    Timer.periodic(Duration(seconds: 5), (timer) {
      lerPh();
      setState(() async{
        now = DateTime.now();
        agora = DateFormat('kk:mm').format(now);
        if( agora == '12:00')gravarpHBanco();
      });
    });
    
  }

  void dosarCloro() async {
    setState(() {
      this.dosarcloro++;
    });
    blueconnect.output.add(utf8.encode("D" + "\r\n"));
    await blueconnect.output.allSent;
    print('DOSAGEM: $dosarcloro');
  }

  void alterarAutomatico() async {
    setState(() {
      if (this.automatico == true) {
        this.automatico = false;
      } else {
        this.automatico = true;
      }
    });
    if (this.automatico == false)
      blueconnect.output.add(utf8.encode("E" + "\r\n"));
    await blueconnect.output.allSent;
    if (this.automatico == true)
      blueconnect.output.add(utf8.encode("A " + "\r\n"));
    await blueconnect.output.allSent;
    print('AUTOMATICO: $automatico');
  }

  void alterarMotor() async {
    setState(() {
      if (this.motor == true) {
        this.motor = false;
      } else {
        this.motor = true;
      }
    });
    if (this.motor == false) blueconnect.output.add(utf8.encode("C" + "\r\n"));
    await blueconnect.output.allSent;
    if (this.motor == true) blueconnect.output.add(utf8.encode("B" + "\r\n"));
    await blueconnect.output.allSent;
    print('MOTOR: $motor');
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

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;

    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);

    if (~index != 0) {
      setState(() {
        recebido = backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, index);

        _messageBuffer = dataString.substring(index);
        ph = recebido.trim();
        print(ph);
        
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void lerPh() async {
    blueconnect.output.add(utf8.encode("L" + "\r\n"));
    await blueconnect.output.allSent;
  }

  void gravarpHBanco() async {
    
    if(ph.length > 4){
      showToast("pH invalido refazer leitura!");
    }else{
    
    setState(() async {
      now = DateTime.now();
      //String agora = DateFormat('yyyy-MM-dd – kk:mm').format(now);
      agora = DateFormat('dd/MM/yyyy').format(now);
      
      print(agora);
      Ph obj = Ph(ph, agora);
      if (agoraux == agora) {
        int resultado = await _db.excluirumPhdata(agora);
        resultado = await _db.inserirPh(obj);
        agoraux = DateFormat('dd/MM/yyyy').format(now);
        
        if (resultado != null) {
          showToast("pH Atualizado");
        } else {
          showToast("erro ao atualizar pH");
        }
      } else{
        int resultado = await _db.inserirPh(obj);
        
        if (resultado != null) {
          agoraux = DateFormat('dd/MM/yyyy').format(now);
          showToast("pH Salvo no Banco de Dados");
        } else {
          showToast("erro ao salvar pH");
        }
      }
    });
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      blueconnect.dispose();
      blueconnect = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('AppPool'),
        ),
        body: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              color: Colors.blue[600],
              child: Text(
                "LEITURA DO PH ",
                style: TextStyle(fontSize: 30, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            new InkWell(
              onTap: () {
                lerPh();
              },
              child: Ink(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                color: Colors.blue[600],
                child: Text(
                  ph,
                  style: TextStyle(fontSize: 100, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            RaisedButton.icon(
                  icon: Icon(Icons.save),
                  onPressed: gravarpHBanco,
                  label: Text(
                    "Atualizar Banco",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
            Container(
                width: double.infinity,
                margin: EdgeInsets.all(20),
                child: Text(
                  "LIGAR/DESLIGAR MOTOR: ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                )),
            Transform.scale(
              scale: 1.4,
              child: Switch(
                value: motor,
                onChanged: automatico
                    ? null
                    : (value) {
                        setState(() {
                          alterarMotor();
                        });
                      },
                activeTrackColor: Colors.blueGrey,
                activeColor: Colors.blue,
              ),
            ),
            Container(
                width: double.infinity,
                margin: EdgeInsets.all(20),
                child: Text(
                  "AUTOMATICO: ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                )),
            Transform.scale(
              scale: 1.4,
              child: Switch(
                value: automatico,
                onChanged: (value) {
                  setState(() {
                    alterarAutomatico();
                  });
                },
                activeTrackColor: Colors.blueGrey,
                activeColor: Colors.blue,
              ),
            ),
            Container(
              width: double.infinity,
              height: 75,
              margin: EdgeInsets.fromLTRB(0, 59, 0, 0),
              child: RaisedButton(
                  child: Text(
                    'DOSAR CLORO',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  onPressed: automatico ? null : dosarCloro,
                  color: Colors.blue[600]),
            )
          ],
        ),
    );
  }
}
