class LatestInfo {
  final int cases;
  final int deaths;
  final int recovered;

  LatestInfo({this.cases, this.deaths, this.recovered});

  factory LatestInfo.fromJson(Map<String, dynamic> json) {
    return LatestInfo(
      cases: json['cases'],
      deaths: json['deaths'],
      recovered: json['recovered']
    );
  }
}
