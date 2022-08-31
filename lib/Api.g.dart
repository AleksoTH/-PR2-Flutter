// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statistikk _$StatistikkFromJson(Map<String, dynamic> json) {
  return Statistikk(
    fryser: json['fryser'] as int,
    kjoleskap: json['kjoleskap'] as int,
    komfyr: json['komfyr'] as int,
    vaskemaskin: json['vaskemaskin'] as int,
    torkeprodukt: json['torkeprodukt'] as int,
    oppvaskmaskin: json['oppvaskmaskin'] as int,
    ankommet: json['ankommet'] as int,
    skal_hentes: json['skal_hentes'] as int,
    skal_vaskes: json['skal_vaskes'] as int,
    skrotet: json['skrotet'] as int,
    solgt: json['solgt'] as int,
  );
}

Map<String, dynamic> _$StatistikkToJson(Statistikk instance) =>
    <String, dynamic>{
      'fryser': instance.fryser,
      'kjoleskap': instance.kjoleskap,
      'komfyr': instance.komfyr,
      'vaskemaskin': instance.vaskemaskin,
      'torkeprodukt': instance.torkeprodukt,
      'oppvaskmaskin': instance.oppvaskmaskin,
      'ankommet': instance.ankommet,
      'skal_hentes': instance.skal_hentes,
      'skal_vaskes': instance.skal_vaskes,
      'skrotet': instance.skrotet,
      'solgt': instance.solgt,
    };

Kunde _$KundeFromJson(Map<String, dynamic> json) {
  return Kunde(
    kundeid: json['kundeid'] as String,
    navn: json['navn'] as String,
    adresse: json['adresse'] as String,
    postnummer: json['postnummer'] as int,
    notater: json['notater'] as String,
    telefonnummer: json['telefonnummer'] as int,
  );
}

Map<String, dynamic> _$KundeToJson(Kunde instance) => <String, dynamic>{
      'kundeid': instance.kundeid,
      'navn': instance.navn,
      'adresse': instance.adresse,
      'postnummer': instance.postnummer,
      'notater': instance.notater,
      'telefonnummer': instance.telefonnummer,
    };

Produkt _$ProduktFromJson(Map<String, dynamic> json) {
  return Produkt(
    barkode: json['barkode'] as String,
    kundeid: json['kundeid'] as String,
    registrertDato: json['registrertDato'] as String,
    statusDato: json['statusDato'] as String,
    modellnummer: json['modellnummer'] as String,
    serienummer: json['serienummer'] as String,
    notater: json['notater'] as String,
    merke: json['merke'] as String,
    lokasjon: json['lokasjon'] as String,
    produkttype:
        _$enumDecodeNullable(_$ProduktTypeEnumMap, json['produkttype']),
    status: _$enumDecodeNullable(_$StatusEnumMap, json['status']),
  );
}

Map<String, dynamic> _$ProduktToJson(Produkt instance) => <String, dynamic>{
      'barkode': instance.barkode,
      'kundeid': instance.kundeid,
      'registrertDato': instance.registrertDato,
      'statusDato': instance.statusDato,
      'modellnummer': instance.modellnummer,
      'serienummer': instance.serienummer,
      'merke': instance.merke,
      'notater': instance.notater,
      'lokasjon': instance.lokasjon,
      'produkttype': _$ProduktTypeEnumMap[instance.produkttype],
      'status': _$StatusEnumMap[instance.status],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$ProduktTypeEnumMap = {
  ProduktType.KJOLESKAP: 'KJOLESKAP',
  ProduktType.FRYSER: 'FRYSER',
  ProduktType.VASKEMASKIN: 'VASKEMASKIN',
  ProduktType.OPPVASKMASKIN: 'OPPVASKMASKIN',
  ProduktType.TORKEPRODUKT: 'TORKEPRODUKT',
  ProduktType.KOMFYR: 'KOMFYR',
  ProduktType.ANDRE: 'ANDRE',
};

const _$StatusEnumMap = {
  Status.UKJENT: 'UKJENT',
  Status.SOLGT: 'SOLGT',
  Status.SKAL_VASKES: 'SKAL_VASKES',
  Status.ANKOMMET: 'ANKOMMET',
  Status.SKAL_HENTES: 'SKAL_HENTES',
  Status.SKROTET: 'SKROTET',
};

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    baseUrl ??= 'https://192.168.1.236:8080';
  }

  final Dio _dio;

  String baseUrl;

  @override
  Future<List<Kunde>> searchKunder(sok) async {
    ArgumentError.checkNotNull(sok, 'sok');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'search': sok};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<List<dynamic>>('/kunder/søk',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    var value = _result.data
        .map((dynamic i) => Kunde.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  @override
  Future<Kunde> getKundeById(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('/kunder/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = Kunde.fromJson(_result.data);
    return value;
  }

  @override
  Future<dynamic> slettKunde(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request('/kunder/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'DELETE',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }

  @override
  Future<Kunde> nykunde(body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body?.toJson() ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('/kunder/',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'PUT',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = Kunde.fromJson(_result.data);
    return value;
  }

  @override
  Future<Kunde> oppdaterKunde(id, body) async {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body?.toJson() ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('/kunder/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = Kunde.fromJson(_result.data);
    return value;
  }

  @override
  Future<Produkt> nyttProdukt(id, body) async {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body?.toJson() ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>(
        '/kunder/$id/produkter',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'PUT',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = Produkt.fromJson(_result.data);
    return value;
  }

  @override
  Future<dynamic> slettProdukt(id, produktid) async {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(produktid, 'produktid');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request('/kunder/$id/produkter/$produktid',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'DELETE',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }

  @override
  Future<List<Produkt>> listProdukter(id, sok) async {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(sok, 'sok');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'navn': sok};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<List<dynamic>>('/kunder/$id/produkter',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    var value = _result.data
        .map((dynamic i) => Produkt.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  @override
  Future<Statistikk> getMonthlyStats(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>(
        '/kunder/$id/mstats',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = Statistikk.fromJson(_result.data);
    return value;
  }

  @override
  Future<Produkt> oppdaterProdukt(id, body) async {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body?.toJson() ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('/produkter/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = Produkt.fromJson(_result.data);
    return value;
  }

  @override
  Future<Produkt> getProdukt(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('/produkter/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = Produkt.fromJson(_result.data);
    return value;
  }
}
