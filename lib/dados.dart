import 'package:appool/Model/pH.dart';
import 'package:appool/utils/PhHelpers.dart';
import 'package:flutter/material.dart';
import 'package:appool/grafico.dart';

class Dados extends StatefulWidget {
  @override
  _DadosState createState() => _DadosState();
}

class _DadosState extends State<Dados> {
  String leitura = '15.5';
  DateTime now;
  PhHelpers _db = PhHelpers();

  List<Ph> listaph = List<Ph>();

  void removerph(int id) async {
    int resultado = await _db.excluirumPh(id);
    recuperarPh();
  }
  
  void adicionarpH(){
       setState(() async {
        Ph obj7 = Ph('8.10', '25/05/2021');
        Ph obj8 = Ph('7.20', '26/05/2021');
        Ph obj9 = Ph('6.90', '27/05/2021');
        Ph obj10 = Ph('6.70', '28/05/2021');
        Ph obj = Ph('7.10', '29/05/2021');
        Ph obj1 = Ph('7.60', '30/05/2021');
        Ph obj2 = Ph('7.10', '31/05/2021');
        Ph obj3 = Ph('6.70', '01/06/2021');
        Ph obj4 = Ph('7.00', '02/06/2021');
        Ph obj5 = Ph('7.20', '03/06/2021');
        Ph obj6 = Ph('7.00', '04/06/2021');
        int resultado = await _db.inserirPh(obj7);
         resultado = await _db.inserirPh(obj8);
         resultado = await _db.inserirPh(obj9);
         resultado = await _db.inserirPh(obj10);
         resultado = await _db.inserirPh(obj);
         resultado = await _db.inserirPh(obj1);
         resultado = await _db.inserirPh(obj2);
         resultado = await _db.inserirPh(obj3);
         resultado = await _db.inserirPh(obj4);
         resultado = await _db.inserirPh(obj5);
         resultado = await _db.inserirPh(obj6);
       });
  }

  void removertodos() async {
    int resultado = await _db.excluirtodosPh();
    recuperarPh();
  }

  void exibirtelaconfirma() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Limpar"),
            content: Text("Você tem certeza que deseja excluir tudo?"),
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
                  Navigator.pop(context);
                  removertodos();
                },
              )
            ],
          );
        });
  }

  void exibirtelaconfirmaid(int id) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Excluir pH"),
            content: Text("Você tem certeza que deseja excluir?"),
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
                  Navigator.pop(context);
                  removerph(id);
                },
              )
            ],
          );
        });
  }

  void recuperarPh() async {
    List phRecuperados = await _db.listarPh();
    //print("Ph: " + phRecuperados.toString());

    List<Ph> listatemporaria = List<Ph>();

    for (var item in phRecuperados) {
      Ph c = Ph.deMapParaModel(item);
      listatemporaria.add(c);
    }

    setState(() {
      listaph = listatemporaria;
    });

    listatemporaria = null;
  }

  void grafico() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) => GraficoPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    recuperarPh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AppPool'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 75,
                child: RaisedButton.icon(
                  color: Colors.blue[500],
                  icon: Icon(Icons.delete_outline),
                  onPressed: exibirtelaconfirma,
                  label: Text(
                    'LIMPAR',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  height: 75,
                  child: RaisedButton.icon(
                    color: Colors.blue[500],
                    icon: Icon(Icons.refresh),
                    onPressed: recuperarPh,
                    label: Text(
                      'ATUALIZAR',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Container(
                height: 75,
                child: RaisedButton.icon(
                  color: Colors.blue[500],
                  icon: Icon(Icons.insights),
                  onPressed: grafico,
                  label: Text(
                    'GRAFICO',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            
            ],
          ),
          Expanded(
            
            child: ListView.builder(
                itemCount: listaph.length,
                itemBuilder: (context, index) {
                  final Ph obj = listaph[index];
                  
                  return Card(
                      child: ListTile(
                    title: Text(
                        obj.data + "                     PH: " + obj.valor),
                    trailing: GestureDetector(
                      onTap: () {
                        exibirtelaconfirmaid(obj.id);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ));
                }),
          ),
        ],
      ),
    );
  }
}
