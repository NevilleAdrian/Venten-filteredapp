import 'package:filteredapp/models/Cars.dart';
import 'package:filteredapp/models/Filtercar.dart';
import 'package:filteredapp/services/network_helper.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'future_helper.dart';
import 'package:intl/intl.dart';

class MyHomepage extends StatefulWidget {
  @override
  _MyHomepageState createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  Future<List<Car>> futureCars;
  NetworkHelper carNetworkHelper = NetworkHelper();

  Future<List<Car>> futureTask() async {
    var filter = await carNetworkHelper.getCarFilter();
    var result =
        await rootBundle.loadString("assets/venten/car_ownsers_data.csv");
    var data = CsvToListConverter().convert(result);
    List<Car> cars = Car().createCars(data);
    setState(() {
      fc = filter;
      availableCars = cars;
      filteredCars = cars;
    });
    return Future.value(cars);
  }

  List<FilterCar> fc = [];

  onFilter(FilterCar filter) {
    setState(() {
      filteredCars = availableCars.where((element) {
        return withinDateRange(
                element.car_model_year, filter.startYear, filter.endYear) &&
            isOfGender(element.gender, filter.gender) &&
            withinCountries(element.country, filter.countries) &&
            hasColor(element.car_color, filter.colors);
      }).toList();
    });
  }

  bool withinDateRange(int carDate, int startYear, int endYear) =>
      carDate >= startYear && carDate <= endYear;
  bool isOfGender(String carGender, String filterGender) =>
      carGender.toLowerCase() == filterGender.toLowerCase();
  bool withinCountries(String country, List<String> countries) =>
      countries.map((e) => e.toLowerCase()).contains(country.toLowerCase());
  bool hasColor(String color, List<String> colors) =>
      colors.map((e) => e.toLowerCase()).contains(color.toLowerCase());

  Color getColor(int index) {
    if (index == 0) return Colors.purple;
    if (index == 1) return Colors.green;
    if (index == 2) return Colors.deepOrange;
    if (index == 3) return Colors.blueAccent;
    if (index == 4) return Colors.pink;
    if (index == 5) return Colors.teal;
    if (index == 6) return Colors.amberAccent;
  }

  @override
  void initState() {
    futureCars = futureTask();
    super.initState();
  }

  List<Car> availableCars = List<Car>();
  List<Car> filteredCars = List<Car>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Filtered App',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1,
        ),
        body: SafeArea(
          child: FutureHelper<List<Car>>(
              task: futureCars,
              builder: (context, data) {
                List<Car> cars = data;
                print('data${cars.first.last_name}');
                return Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 220,
                          child: ListView.separated(
                              separatorBuilder: (_, __) => SizedBox(
                                    width: 20,
                                  ),
                              scrollDirection: Axis.horizontal,
                              itemCount: fc.length,
                              itemBuilder: (_, int index) {
                                FilterCar filter = fc[index];
                                return GestureDetector(
                                  onTap: () {
                                    onFilter(filter);
                                  },
                                  child: FilterItem(
                                      color: getColor(index),
                                      dateRange:
                                          '${filter.startYear} - ${filter.endYear} ',
                                      gender: filter.gender,
                                      countries: filter.countries?.join(', '),
                                      colors: filter.colors?.join(', ')),
                                );
                              }),
                        ),
                        Expanded(
                            flex: 3,
                            child: Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: filteredCars.length == 0
                                  ? Text(
                                      "no item found",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredCars.length,
                                      itemBuilder: (_, int index) {
                                        Car car = filteredCars[index];
                                        return Container(
                                          child: Column(
                                            children: <Widget>[
                                              CarDetail(
                                                title: 'Full Name',
                                                description:
                                                    '${car.first_name} ${car.last_name}',
                                              ),
                                              CarDetail(
                                                title: 'Email',
                                                description: car.email,
                                              ),
                                              CarDetail(
                                                title: 'Country',
                                                description: car.country,
                                              ),
                                              CarDetail(
                                                title:
                                                    'Car Make, Color and Year',
                                                description:
                                                    '${car.car_model}, ${car.car_color} & ${car.car_color}',
                                              ),
                                              CarDetail(
                                                title: 'Gender',
                                                description: car.gender,
                                              ),
                                              CarDetail(
                                                title: 'Job Title',
                                                description: car.job_title,
                                              ),
                                              CarDetail(
                                                title: 'Bio',
                                                description: car.bio,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                            ))
                      ],
                    ));
              }),
        ));
  }
}

class CarDetail extends StatelessWidget {
  final String title;
  final String description;
  const CarDetail({this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(title),
      title: Text(description),
    );
  }
}

class FilterItem extends StatelessWidget {
  final Color color;
  final String dateRange;
  final String gender;
  final String countries;
  final String colors;

  FilterItem(
      {this.color, this.dateRange, this.gender, this.countries, this.colors});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            dateRange,
            style:
                kTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            toBeginningOfSentenceCase(gender),
            style: kTextStyle,
          ),
          SizedBox(
            height: 10.0,
          ),
          SizedBox(
            width: 170.0,
            child: Text(
              countries,
              style: kTextStyle,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          SizedBox(
            width: 190.0,
            child: Text(
              colors,
              style: kTextStyle,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}

const kTextStyle = TextStyle(fontSize: 14, color: Colors.white);
