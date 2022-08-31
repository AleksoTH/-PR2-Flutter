import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'Api.g.dart';

var dio = new Dio();
var client = RestClient(dio);


@RestApi(baseUrl: "https://127.0.0.1:8080")
abstract class RestClient {
  factory RestClient(Dio dio) = _RestClient;

  @GET("/kunder/søk")
  Future<List<Kunde>> searchKunder(@Query("search") String sok);

  @GET("/kunder/{id}")
  Future<Kunde> getKundeById(@Path("id") String id);

  @DELETE("/kunder/{id}")
  Future slettKunde(@Path("id") String id);

  @PUT("/kunder/")
  Future<Kunde> nykunde(@Body() Kunde body);

  @POST("/kunder/{id}")
  Future<Kunde> oppdaterKunde(@Path("id") String id,@Body() Kunde body);

  @PUT("/kunder/{id}/produkter")
  Future<Produkt> nyttProdukt(@Path("id") String id,@Body() Produkt body);

  @DELETE("/kunder/{id}/produkter/{produktid}")
  Future slettProdukt(@Path("id") String id,@Path("produktid") String produktid);

  @GET("/kunder/{id}/produkter")
  Future<List<Produkt>> listProdukter(@Path("id") String id,@Query("navn") String sok);

  @GET("/kunder/{id}/mstats")
  Future<Statistikk> getMonthlyStats(@Path("id") String id);

  @POST("/produkter/{id}")
  Future<Produkt> oppdaterProdukt(@Path("id") String id,@Body() Produkt body);

  @GET("/produkter/{id}")
  Future<Produkt> getProdukt(@Path("id") String id);

}
enum Status{
  UKJENT,
  SOLGT,
  SKAL_VASKES,
  ANKOMMET,
  SKAL_HENTES,
  SKROTET
}

enum ProduktType{
  KJOLESKAP,
  FRYSER,
  VASKEMASKIN,
  OPPVASKMASKIN,
  TORKEPRODUKT,
  KOMFYR,
  ANDRE
}
@JsonSerializable()
class Statistikk {
  int fryser = 0;
  int kjoleskap = 0;
  int komfyr = 0;
  int vaskemaskin = 0;
  int torkeprodukt = 0;
  int oppvaskmaskin = 0;

  int ankommet = 0;
  int skal_hentes = 0;
  int skal_vaskes = 0;
  int skrotet = 0;
  int solgt = 0;

  Statistikk({this.fryser,this.kjoleskap,this.komfyr,this.vaskemaskin,this.torkeprodukt,this.oppvaskmaskin,this.ankommet,this.skal_hentes,this.skal_vaskes,this.skrotet,this.solgt});

  factory Statistikk.fromJson(Map<String, dynamic> json) => _$StatistikkFromJson(json);
  Map<String, dynamic> toJson() => _$StatistikkToJson(this);
}

@JsonSerializable()
class Kunde {
  String kundeid;
  String navn;
  String adresse;
  int postnummer;
  String notater;
  int telefonnummer;

  Kunde({this.kundeid, this.navn, this.adresse, this.postnummer,this.notater,this.telefonnummer});

  factory Kunde.fromJson(Map<String, dynamic> json) => _$KundeFromJson(json);
  Map<String, dynamic> toJson() => _$KundeToJson(this);
}

@JsonSerializable()
class Produkt {

  String barkode;

  String kundeid;

  String registrertDato;

  String statusDato;

  String modellnummer;

  String serienummer;

  String merke;

  String notater;

  String lokasjon;

  ProduktType produkttype;

  Status status;

  Produkt({this.barkode, this.kundeid, this.registrertDato, this.statusDato,this.modellnummer,this.serienummer,this.notater,this.merke,this.lokasjon,this.produkttype,this.status});

  factory Produkt.fromJson(Map<String, dynamic> json) => _$ProduktFromJson(json);
  Map<String, dynamic> toJson() => _$ProduktToJson(this);
}