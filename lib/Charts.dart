
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:mycompany/main.dart';

import 'Api.dart';

class BarChartSample1 extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => BarChartSample1State();
}
List<Widget> space(Iterable<Widget> children) => children.expand(
        (item) sync* { yield const SizedBox(width: 20); yield item; }).skip(1).toList();
List<Widget> space2(Iterable<Widget> children) => children.expand(
        (item) sync* { yield const SizedBox(width: 15); yield item; }).skip(1).toList();

class BarChartSample1State extends State<BarChartSample1> {
  final Color barBackgroundColor = const Color(0xff72d8bf);
  ValueNotifier<Statistikk> stat = ValueNotifier<Statistikk>(new Statistikk());

  @override
  Widget build(BuildContext context) {
    if(denneKunde != null && denneKunde.kundeid != null) {
      client.getMonthlyStats(denneKunde.kundeid).then((value) =>
      stat.value = value).onError((error, stackTrace) => errorCatchy(error, stackTrace));
    }
    return ValueListenableBuilder(
        valueListenable: stat,
        builder: (context, value, child) => Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: const Color(0xff81e5cd),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  'Statistikk',
                  style: TextStyle(
                      color: const Color(0xff0f4a3c), fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Denne måned på denne kunde',
                  style: TextStyle(
                      color: const Color(0xff379982), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 28,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: space([
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.fryser.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Icon(Icons.ac_unit, color: Colors.blue),
                            ),
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.kjoleskap.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Icon(Icons.ac_unit_outlined, color: Colors.cyan),
                            ),
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.komfyr.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Icon(Icons.ad_units, color: Colors.grey),
                            ),
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.oppvaskmaskin.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Icon(Icons.waterfall_chart, color: Colors.grey),
                            ),
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.torkeprodukt.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Icon(Icons.waves_rounded, color: Colors.grey),
                            ),
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.vaskemaskin.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Icon(Icons.adjust, color: Colors.grey),
                            ),
                          ],)
                      ),
                      Divider(),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: space2([
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(stat.value.ankommet.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Text("ANK   "),
                            ),
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.solgt.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Text("SOLGT   "),
                            ),
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.skal_vaskes.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Text("VASK   "),
                            ),
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.skal_hentes.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Text("HENTES   "),
                            ),
                            Badge(
                              badgeColor: Colors.blue,
                              badgeContent: Text(
                                stat.value.skrotet.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: Text("SKR   "),
                            )
                          ],)
                      )
                    ],),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
    }

  errorCatchy(error, stacktrace) {
    debugPrintStack(stackTrace: stacktrace);
  }
}