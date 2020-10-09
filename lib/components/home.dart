import 'package:filteredapp/models/Cars.dart';
import 'package:filteredapp/models/Filtercar.dart';
import 'package:filteredapp/services/network_helper.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'future_helper.dart';

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

  @override
  void initState() {
    futureCars = futureTask();
    super.initState();
  }

  List<Car> availableCars = List<Car>();
  List<Car> filteredCars = List<Car>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Filtered'),
      ),
      body: FutureHelper<List<Car>>(
          task: futureCars,
          builder: (context, data) {
            List<Car> cars = data;
            print('data${cars.first.last_name}');
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      itemCount: fc.length,
                      itemBuilder: (_, int index) {
                        FilterCar filter = fc[index];
                        return GestureDetector(
                            onTap: () {
                              onFilter(filter);
                            },
                            child: Column(
                              children: <Widget>[
                                CarDetail(
                                  title: 'Date Range',
                                  description:
                                      '${filter.startYear} - ${filter.endYear} ',
                                ),
                                CarDetail(
                                    title: 'Gender',
                                    description: filter.gender),
                                CarDetail(
                                    title: 'Countries',
                                    description: filter.countries?.join(',')),
                                CarDetail(
                                    title: 'Color',
                                    description: filter.colors?.join(',')),
                              ],
                            ));
                      }),
                ),
                Expanded(
                    child: filteredCars.length == 0 ? Text("no item found", style: TextStyle(color: Colors.black),) : ListView.builder(
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
                                  title: 'Car Make, Color and Year',
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
                          ) ;
                        }))
              ],
            );
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
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(20)
      ),
    );
  }
}
