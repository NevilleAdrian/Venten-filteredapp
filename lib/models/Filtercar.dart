// To parse this JSON data, do
//
//     final filterCar = filterCarFromJson(jsonString);

import 'dart:convert';

List<FilterCar> filterCarFromJson(String str) => List<FilterCar>.from(json.decode(str).map((x) => FilterCar.fromJson(x)));

String filterCarToJson(List<FilterCar> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FilterCar {
  FilterCar({
    this.id,
    this.startYear,
    this.endYear,
    this.gender,
    this.countries,
    this.colors,
  });

  int id;
  int startYear;
  int endYear;
  String gender;
  List<String> countries;
  List<String> colors;

  factory FilterCar.fromJson(Map<String, dynamic> json) => FilterCar(
    id: json["id"],
    startYear: json["start_year"],
    endYear: json["end_year"],
    gender: json["gender"],
    countries: List<String>.from(json["countries"].map((x) => x)),
    colors: List<String>.from(json["colors"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "start_year": startYear,
    "end_year": endYear,
    "gender": gender,
    "countries": List<dynamic>.from(countries.map((x) => x)),
    "colors": List<dynamic>.from(colors.map((x) => x)),
  };
}
