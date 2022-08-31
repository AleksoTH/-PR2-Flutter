import 'dart:io';
import 'dart:math';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Api.dart';
import 'Charts.dart';
import 'QRVIEW.dart';

Kunde denneKunde = new Kunde();
Produkt detteProdukt = new Produkt();

void main() {
  dio.options.headers["authorization"] = "Basic YWRtaW46dGVzdA==";
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  };
  runApp(MyApp());
  Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Department',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

DebugPrintCallback debugPrint = debugPrintThrottled;
Function errorCatch(e, stacktrace) {
  debugPrint(e.toString());
  switch (e.runtimeType) {
    case DioError:
      final res = (e as DioError).response;
      if (res == null) break;
      debugPrint("Got error : ${res.statusCode} -> ${res.statusMessage}");
      break;
    default:
  }
  debugPrint(stacktrace.toString());
  return null;
}

String searchString = "";

class SearchStatus extends StatefulWidget {
  @override
  Search createState() => Search();
}

class Search extends State<SearchStatus> {
  @override
  Widget build(BuildContext context) {
    final builder = FutureBuilder(
      future: client.searchKunder(searchString),
      builder: (context, snap) {
        switch (snap.connectionState) {
          case ConnectionState.none:
            return Text("test");
          case ConnectionState.done:
            if (!snap.hasData) {
              return Text("Error " + snap.error.toString());
            }
            List<Kunde> data = snap.data;
            final list = ListView.builder(
              itemCount: data.length,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  child: ListTile(
                      isThreeLine: true,
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        denneKunde = data[index];
                        DefaultTabController.of(context).animateTo(1);
                      },
                      title: Text("${data[index].navn}",
                          style: TextStyle(fontSize: 15.0)),
                      subtitle: Text("" +
                          data[index].adresse +
                          ", " +
                          data[index].postnummer.toString() +
                          "\nTLF: " +
                          data[index].telefonnummer.toString() +
                          "\nNotater: " +
                          data[index].notater)),
                  background: Container(
                    color: Colors.red,
                  ),
                  key: ValueKey<Kunde>(data[index]),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      denneKunde = data[index];
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => KundeInfo(),
                          ));
                      return false;
                    } else if (direction == DismissDirection.startToEnd) {
                      showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Slett kunde?'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('Vill du slette kunde?'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Ja'),
                                  onPressed: () {
                                    debugPrint(data[index].kundeid.toString());
                                    client
                                        .slettKunde(data[index].kundeid)
                                        .onError((e, stackTrace) =>
                                            errorCatch(e, stackTrace));

                                    Navigator.of(context).pop();
                                    setState(() {
                                      data.removeAt(index);
                                    });
                                  },
                                ),
                                TextButton(
                                  child: Text('Nei'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    }
                    return false;
                  },
                );
              },
            );
            return snap.hasError
                ? Text((snap.error as DioError).response.toString())
                : list;
        }
        return Text("Loading");
      },
    );
    return Scaffold(
        body: Column(children: [
      Container(
          child: TextField(
        onSubmitted: sok,
        decoration: new InputDecoration(
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "Søk kundenavn",
            fillColor: Colors.white70),
      )),
      Expanded(child: Container(child: builder))
    ]));
  }

  void sok(String value) {
    if (value.isEmpty) {
      searchString = "";
    } else {
      searchString = "navn:" + value + "*";
    }
    setState(() {});
  }
}

class KundeInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6200EE),
        title: Text('Kunde'),
      ),
      body: KundeformFull(),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.account_box), text: 'Kunder'),
                Tab(
                    icon: Icon(Icons.wysiwyg),
                    text: 'Produkter på denne kunde'),
              ],
            ),
            title: Center(
                child: SizedBox(
                    child: Image.asset('assets/images/title.png', height: 60))),
          ),
          endDrawer: Drawer(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Center(
                    child: SizedBox(
                        child: Image.asset('assets/images/drawer.png',
                            height: 60))),
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
              ),
              ListTile(
                title: Text('Scan qr kode'),
                onTap: ()  {
                  Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => CameraApp(),
                      ));

                },
              ),
            ],
          )),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Transform(
                transform: Matrix4.identity()..translate(0.0, -32.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add),
                  onPressed: () =>
                      addProdukt(DefaultTabController.of(context).index),
                ),
              ),
            ],
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [SearchStatus(), ProduktStatus()],
          ),
        );
      }),
    );
  }

  addProdukt(int index) {
    Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => choosePath(index),
        ));
  }

  choosePath(int index) {
    switch (index) {
      case 0:
        return KundeDialog();
      case 1:
        return ProduktDialog();
    }
  }
}

class ProduktStatus extends StatefulWidget {
  @override
  Produkter createState() => Produkter();
}

String produktsok = "";

class Produkter extends State<ProduktStatus> {
  @override
  Widget build(BuildContext context) {
    if (denneKunde.kundeid == null) {
      return Text("");
    }
    final builder = FutureBuilder(
      future: client.listProdukter(denneKunde.kundeid, produktsok),
      builder: (context, snap) {
        switch (snap.connectionState) {
          case ConnectionState.none:
            return Text("Starter...");
          case ConnectionState.done:
            if (snap.hasError) {
              DioError ee = snap.error;
              debugPrint(ee.request.path);
              return Text("Error");
            }
            if (!snap.hasData) {
              return Text("Ingen produkter");
            }
            List<Produkt> data = snap.data;
            final list = ListView.builder(
              itemCount: data.length,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  child: ListTile(
                      onTap: () {
                        detteProdukt = data[index];
                        Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  ProductEditEnhance(),
                            ));
                      },
                      isThreeLine: true,
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.black,
                        child: Text(
                          "${data[index].merke?.substring(0, min(3, data[index].merke?.length))}",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      title: Text("${data[index].modellnummer}",
                          style: TextStyle(fontSize: 15.0)),
                      subtitle: Text(data[index].serienummer +
                          "\nStatus: " +
                          data[index].statusDato?.substring(0, 10) +
                          ", " +
                          data[index]
                              .status
                              .toString()
                              .replaceAll("Status.", ""))),
                  background: Container(
                    color: Colors.red,
                  ),
                  key: ValueKey<Produkt>(data[index]),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return false;
                    } else if (direction == DismissDirection.startToEnd) {
                      detteProdukt = data[index];
                      showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Slett produkt?'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('Vill du slette produkt?'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Ja'),
                                  onPressed: () {
                                    debugPrint(denneKunde.kundeid +
                                        " : " +
                                        detteProdukt.barkode);
                                    client
                                        .slettProdukt(denneKunde.kundeid,
                                            detteProdukt.barkode)
                                        .onError((e, stackTrace) =>
                                            errorCatch(e, stackTrace));

                                    Navigator.of(context).pop();
                                    setState(() {
                                      data.removeAt(index);
                                    });
                                  },
                                ),
                                TextButton(
                                  child: Text('Nei'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    }
                    return false;
                  },
                );
              },
            );
            return snap.hasError
                ? Text((snap.error as DioError).response.toString())
                : list;
        }
        return Text("Loading");
      },
    );
    return Scaffold(
        body: Column(children: [
      Container(height: 200, child: BarChartSample1()),
      Container(
          child: TextField(
        onSubmitted: sok,
        decoration: new InputDecoration(
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "Søk modell",
            fillColor: Colors.white70),
      )),
      Expanded(child: builder)
    ]));
  }

  void sok(String value) {
    if (value.isEmpty) {
      produktsok = "";
    } else {
      produktsok = value;
    }
    setState(() {});
  }
}

class ProductEditEnhance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6200EE),
        title: Text('Produkt'),
      ),
      body: ProduktformFull(),
    );
  }
}

class ProduktDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6200EE),
        title: Text('Legg til produkt'),
      ),
      body: Center(
        child: Produktform(),
      ),
    );
  }
}

class ProduktformFull extends StatefulWidget {
  @override
  ProduktStateFull createState() {
    return ProduktStateFull();
  }
}

class ProduktStateFull extends State<ProduktformFull> {
  final _formKey = GlobalKey<FormState>();

  Status status;

  @override
  Widget build(BuildContext context) {
    detteProdukt.status = status;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: detteProdukt?.modellnummer,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Skriv inn navn!';
              }
              return null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.mode_edit),
              hintText: 'Modell',
              labelText: 'Modell *',
            ),
            keyboardType: TextInputType.text,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (String value) {
              detteProdukt.modellnummer = value;
            },
          ),
          TextFormField(
            initialValue: detteProdukt?.merke,
            decoration: const InputDecoration(
              icon: Icon(Icons.mode_edit),
              hintText: 'Merke',
              labelText: 'Merke *',
            ),
            keyboardType: TextInputType.name,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (String value) {
              detteProdukt?.merke = value;
            },
          ),
          TextFormField(
            initialValue: detteProdukt?.serienummer,
            decoration: const InputDecoration(
              icon: Icon(Icons.mode_edit),
              hintText: 'Serienummer',
              labelText: 'Serienummer *',
            ),
            keyboardType: TextInputType.text,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (String value) {
              detteProdukt?.serienummer = value;
            },
          ),
          TextFormField(
            readOnly: true,
            initialValue: detteProdukt?.registrertDato,
            decoration: const InputDecoration(
              icon: Icon(Icons.block),
              hintText: 'RegDato',
              labelText: 'RegDato *',
            ),
          ),
          TextFormField(
            initialValue: detteProdukt?.lokasjon,
            decoration: const InputDecoration(
              icon: Icon(Icons.mode_edit),
              hintText: 'Lokasjon',
              labelText: 'Lokasjon *',
            ),
            keyboardType: TextInputType.text,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (String value) {
              detteProdukt?.lokasjon = value;
            },
          ),
          TextFormField(
            initialValue: detteProdukt?.notater,
            decoration: const InputDecoration(
              icon: Icon(Icons.mode_edit),
              hintText: 'Notater',
              labelText: 'Notater *',
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            onSaved: (String value) {
              detteProdukt?.notater = value;
            },
          ),
          new Container(
            padding: new EdgeInsets.all(10.0),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Produkt type:",
                textScaleFactor: 2,
              ),
              new Container(
                padding: new EdgeInsets.all(5.0),
              ),
              DropdownButton<ProduktType>(
                  value: detteProdukt?.produkttype,
                  onChanged: (ProduktType newValue) {
                    detteProdukt?.produkttype = newValue;
                    setState(() {
                    });
                  },
                  items: ProduktType.values.map((ProduktType classType) {
                    return DropdownMenuItem<ProduktType>(
                        value: classType,
                        child: Text(classType
                            .toString()
                            .replaceAll("ProduktType.", "")));
                  }).toList()),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Status :",
                textScaleFactor: 2,
              ),
              new Container(
                padding: new EdgeInsets.all(5.0),
              ),
              DropdownButton<Status>(
                  value: detteProdukt?.status,
                  onChanged: (Status newValue) {
                    detteProdukt?.status = newValue;
                    status = newValue;
                    setState(() {
                    });
                  },
                  items: Status.values.map((Status classType) {
                    return DropdownMenuItem<Status>(
                        value: classType,
                        child: Text(
                            classType.toString().replaceAll("Status.", "")));
                  }).toList()),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  detteProdukt?.registrertDato = null;
                  detteProdukt?.statusDato = null;
                  await client
                      .oppdaterProdukt(detteProdukt.barkode, detteProdukt)
                      .onError(
                          (error, stackTrace) => errorCreate(error, stackTrace))
                      .then((value) => createSuccesse(value));
                }
              },
              child: const Text('Oppdater Produkt'),
            ),
          ),
        ],
      )),
    );
  }

  errorCreate(e, stacktrace) {
    errorCatch(e, stacktrace);
  }

  createSuccess(Kunde value) {
    Navigator.pop(context);
  }

  createSuccesse(Produkt value) {
    Navigator.pop(context);
  }
}

class Produktform extends StatefulWidget {
  @override
  ProduktState createState() {
    return ProduktState();
  }
}

class ProduktState extends State<Produktform> {
  final _formKey = GlobalKey<FormState>();
  final Produkt data = new Produkt();
  ProduktType type = ProduktType.VASKEMASKIN;
  Status status = Status.ANKOMMET;
  @override
  Widget build(BuildContext context) {
    data.status = status;
    data.produkttype = type;
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Skriv inn navn!';
              }
              return null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.mode_edit),
              hintText: 'Modell',
              labelText: 'Modell *',
            ),
            keyboardType: TextInputType.name,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (String value) {
              data.modellnummer = value;
            },
          ),
          TextFormField(
            initialValue: "",
            decoration: const InputDecoration(
              icon: Icon(Icons.mode_edit),
              hintText: 'Merke',
              labelText: 'Merke *',
            ),
            keyboardType: TextInputType.name,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (String value) {
              data.merke = value;
            },
          ),
          new Container(
            padding: new EdgeInsets.all(10.0),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Produkt type:",
                textScaleFactor: 2,
              ),
              new Container(
                padding: new EdgeInsets.all(5.0),
              ),
              DropdownButton<ProduktType>(
                  value: type,
                  onChanged: (ProduktType newValue) {
                    data.produkttype = newValue;
                    type = newValue;
                    setState(() {
                    });
                  },
                  items: ProduktType.values.map((ProduktType classType) {
                    return DropdownMenuItem<ProduktType>(
                        value: classType,
                        child: Text(classType
                            .toString()
                            .replaceAll("ProduktType.", "")));
                  }).toList()),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Status :",
                textScaleFactor: 2,
              ),
              new Container(
                padding: new EdgeInsets.all(5.0),
              ),
              DropdownButton<Status>(
                  value: status,
                  onChanged: (Status newValue) {
                    data.status = newValue;
                    status = newValue;
                    setState(() {
                    });
                  },
                  items: Status.values.map((Status classType) {
                    return DropdownMenuItem<Status>(
                        value: classType,
                        child: Text(
                            classType.toString().replaceAll("Status.", "")));
                  }).toList()),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  await client
                      .nyttProdukt(denneKunde.kundeid, data)
                      .onError(
                          (error, stackTrace) => errorCreate(error, stackTrace))
                      .then((value) => createSuccesse(value));
                }
              },
              child: const Text('Legg til'),
            ),
          ),
        ],
      ),
    );
  }

  errorCreate(e, stacktrace) {
    errorCatch(e, stacktrace);
  }

  createSuccess(Kunde value) {
    Navigator.pop(context);
  }

  createSuccesse(Produkt value) {
    Navigator.pop(context);
  }
}

class KundeformFull extends StatefulWidget {
  @override
  KundeformFullState createState() {
    return KundeformFullState();
  }
}

class KundeformFullState extends State<KundeformFull> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: denneKunde?.navn,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Skriv inn navn!';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.person_add),
                  hintText: 'navn',
                  labelText: 'navn *',
                ),
                keyboardType: TextInputType.name,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.singleLineFormatter
                ],
                onSaved: (String value) {
                  denneKunde.navn = value;
                },
              ),
              TextFormField(
                initialValue: denneKunde?.postnummer?.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Skriv inn postnummer!';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.local_post_office),
                  hintText: 'postnummer',
                  labelText: 'postnummer *',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onSaved: (String value) {
                  denneKunde.postnummer = int.parse(value);
                },
              ),
              TextFormField(
                initialValue: denneKunde.adresse,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Skriv inn adresse!';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.add_road),
                  hintText: 'adresse',
                  labelText: 'adresse *',
                ),
                keyboardType: TextInputType.streetAddress,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.singleLineFormatter
                ],
                onSaved: (String value) {
                  denneKunde.adresse = value;
                },
              ),
              TextFormField(
                initialValue: denneKunde?.telefonnummer?.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Skriv inn telefonnummer!';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  hintText: 'telefonnummer',
                  labelText: 'telefonummer *',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.singleLineFormatter
                ],
                onSaved: (String value) {
                  denneKunde.telefonnummer = int.parse(value);
                },
              ),
              TextFormField(
                maxLines: 5,
                initialValue: denneKunde?.notater,
                decoration: const InputDecoration(
                  icon: Icon(Icons.note_add),
                  hintText: 'notater',
                  labelText: 'notater *',
                ),
                keyboardType: TextInputType.text,
                onSaved: (String value) {
                  denneKunde.notater = value;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      await client
                          .oppdaterKunde(denneKunde.kundeid, denneKunde)
                          .onError((error, stackTrace) =>
                              errorCreate(error, stackTrace))
                          .then((value) => createSuccess(value));
                    }
                  },
                  child: const Text('Oppdater kunde'),
                ),
              ),
            ],
          ),
        ));
  }

  errorCreate(e, stacktrace) {
    errorCatch(e, stacktrace);
  }

  createSuccess(Kunde value) {
    Navigator.pop(context);
  }
}

class Kundeform extends StatefulWidget {
  @override
  KundeformState createState() {
    return KundeformState();
  }
}

class KundeformState extends State<Kundeform> {
  final _formKey = GlobalKey<FormState>();
  final Kunde data = new Kunde();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Skriv inn navn!';
              }
              return null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.person_add),
              hintText: 'navn',
              labelText: 'navn *',
            ),
            keyboardType: TextInputType.name,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (String value) {
              data.navn = value;
            },
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Skriv inn postnummer!';
              }
              return null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.local_post_office),
              hintText: 'postnummer',
              labelText: 'postnummer *',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onSaved: (String value) {
              data.postnummer = int.parse(value);
            },
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Skriv inn adresse!';
              }
              return null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.add_road),
              hintText: 'adresse',
              labelText: 'adresse *',
            ),
            keyboardType: TextInputType.streetAddress,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (String value) {
              data.adresse = value;
            },
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Skriv inn telefonnummer!';
              }
              return null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.phone),
              hintText: 'telefonnummer',
              labelText: 'telefonummer *',
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (String value) {
              data.telefonnummer = int.parse(value);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  await client
                      .nykunde(data)
                      .onError(
                          (error, stackTrace) => errorCreate(error, stackTrace))
                      .then((value) => createSuccess(value));
                }
              },
              child: const Text('Legg til'),
            ),
          ),
        ],
      ),
    );
  }

  errorCreate(e, stacktrace) {
    errorCatch(e, stacktrace);
  }

  createSuccess(Kunde value) {
    Navigator.pop(context);
  }
}

class KundeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6200EE),
        title: Text('Legg til kunde'),
      ),
      body: Center(
        child: Kundeform(),
      ),
    );
  }
}
