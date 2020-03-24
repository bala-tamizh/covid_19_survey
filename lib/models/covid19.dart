class Covid19 {
  final String country;
  final CountryInfo countryInfo;
  final int cases;
  final int deaths;
  final int recovered;

  Covid19({
    this.country, 
    this.countryInfo, 
    this.cases, 
    this.deaths,
    this.recovered
  });

  factory Covid19.fromJson(Map<String, dynamic> json) {
    return Covid19(
      country: json['country'],
      countryInfo: CountryInfo.fromJson(json['countryInfo']),
      cases: json['cases'],
      deaths: json['deaths'],
      recovered: json['recovered']
    );
  }

}

class CountryInfo {
  final num lat;
  final num long;
  final String flag;

  CountryInfo({
    this.lat,
    this.long,
    this.flag
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      lat: json['lat'],
      long: json['long'],
      flag: json['flag']
    );
  }
}

class Covid19List {
  final List<Covid19> list;

  Covid19List({
    this.list
  });

  factory Covid19List.fromJson(List<dynamic> json) {
    List<Covid19> list = new List<Covid19>();
    list = json.map((i) => Covid19.fromJson(i)).toList();
    return new Covid19List(
      list: list
    );
  }

}