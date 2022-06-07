import 'dart:math';

import 'package:appool/Model/pH.dart';
import 'package:appool/dados.dart';
import 'package:appool/utils/PhHelpers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GraficoPage extends StatefulWidget {

  @override
  _GraficoPageState createState() => _GraficoPageState();
}

class _GraficoPageState extends State<GraficoPage> {
  LineChartData data = LineChartData();
  List<Ph> _lidos = List<Ph>();
  double quantidade;
  PhHelpers _db = PhHelpers();

    void recuperarPh() async {
  List phRecuperados = await _db.listarPh();
    //print("Ph: " + phRecuperados.toString());

    List<Ph> listatemporaria = List<Ph>();

    for (var item in phRecuperados) {
      Ph c = Ph.deMapParaModel(item);
      listatemporaria.add(c);
    }
    quantidade = _lidos.length.toDouble();
    print(quantidade);print(quantidade);print('66');
  
    setState(() {
      _lidos = listatemporaria;
      setChartData();
      startCreatingDemoData();
    });

    listatemporaria = null;
  }

  void startCreatingDemoData() async {
    for (int i = 0; i < _lidos.length; i++) {
      //if (i == 0) continue;
      await Future.delayed((Duration(milliseconds: 100))).then((value) {
        final Ph obj = _lidos[i];
        flspots.add(FlSpot(double.parse(i.toString()), double.parse(obj.valor)));
        setState(() {
          setChartData();
        });
      });
    }
  }



  void setChartData() {
    
    print("<_____________>");
    quantidade =_lidos.length.toDouble();
    print(quantidade);
    data = LineChartData(
        gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              );
            }),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTextStyles: (value) => TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            margin: 8,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTextStyles: (value) => TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            margin: 8,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: quantidade-1,
        minY: 0,
        maxY: 14,
        lineBarsData: [
          LineChartBarData(
              spots: flspots,
              isCurved: true,
              colors: gradientColors,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
              ))
        ]);
  }

  List<Color> gradientColors = [
    const Color(0xff0d47a1),
    const Color(0xff90caf9),
  ];

  List<FlSpot> flspots = [];

  @override
  void initState() {
    super.initState();
    recuperarPh();
    setChartData();
    startCreatingDemoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AppPool'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(
              "Gráfico Dias x pH",
              style: TextStyle(
                fontSize: 28,
              ),
              
              ),
          ),
          Container(
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .6,
                width: MediaQuery.of(context).size.width * .9,
                child: LineChart(data),
              ),
            ),
          ),
        ],

      ),
    );
  }
}
