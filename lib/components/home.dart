import 'package:filteredapp/models/Cars.dart';
import 'package:filteredapp/models/Filtercar.dart';
import 'package:filteredapp/services/network_helper.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'future_helper.dart';
import 'package:intl/intl.dart';

List<Car> onFilter(FilterCar filter, List<Car> cars) {
  return cars.where((element) {
    return withinDateRange(
        element.car_model_year, filter.startYear, filter.endYear) &&
        isOfGender(element.gender, filter.gender) &&
        withinCountries(element.country, filter.countries) &&
        hasColor(element.car_color, filter.colors);
  }).toList();

}

bool withinDateRange(int carDate, int startYear, int endYear) =>
    carDate >= startYear && carDate <= endYear;
bool isOfGender(String carGender, String filterGender) =>
    filterGender == null || filterGender == '' || carGender == ''  || carGender == null ||
        carGender.toLowerCase() == filterGender.toLowerCase();
bool withinCountries(String country, List<String> countries) =>
    country == null  || country == ''  || countries.join(',') == '' ||  countries == null ||
        countries.map((e) => e.toLowerCase()).contains(country.toLowerCase());
bool hasColor(String color, List<String> colors) =>
    color == null  ||  color == ''  ||  colors.join(',') == '' || colors == null ||
        colors.map((e) => e.toLowerCase()).contains(color.toLowerCase());

class MyHomepage extends StatefulWidget {
  @override
  _MyHomepageState createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  ScrollController _controller = ScrollController();
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

  _onFilter(FilterCar filter, List<Car> cars, int index) {
    setState(() {
      filteredCars = onFilter(filter, cars);
      currentIndex = index;
    });
    _controller.animateTo(0.0, duration: Duration(microseconds: 2000), curve: Curves.ease);
  }



  @override
  void initState() {
    futureCars = futureTask();
    super.initState();
  }

  List<Car> availableCars = List<Car>();
  List<Car> filteredCars = List<Car>();
  int currentIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0XFF257ACF),
          onPressed: () {
            setState(() {
              filteredCars = availableCars;
              currentIndex = null;
            });
            _controller.animateTo(0.0, duration: Duration(microseconds: 2000), curve: Curves.ease);
          },
          child: Icon(Icons.refresh) ,

      ),
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Color(0xFF333333),
          title: Text(
            'Filtered Cars',
            style: TextStyle(color: Colors.white),
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
                          height: 260,
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
                                    _onFilter(filter, availableCars, index);

                                  },
                                  child: FilterItem(
                                    isActive: currentIndex == index,
                                      color: Color(0xFF333333),
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
                                  ? Center(
                                      child: Text(
                                        "No Item found",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  : ListView.separated(
                                controller: _controller,
                                      separatorBuilder: (_, __) => SizedBox(
                                            height: 20,
                                          ),
                                      itemCount: filteredCars.length,
                                      itemBuilder: (_, int index) {
                                        Car car = filteredCars[index];
                                        return CarDetail(
                                          fullName:'${car.first_name} ${car.last_name}',
                                          email: car.email,
                                          country: car.country,
                                          extras:'${car.car_model}, ${car.car_model_year} & ${car.car_color}',
                                          gender: car.gender,
                                          jobTitle: car.job_title,
                                          bio: car.bio,
                                        );
                                      }),
                            ))
                      ],
                    ));
              }),
        ));
  }
}


class FilterItem extends StatelessWidget {
  final bool isActive;
  final Color color;
  final String dateRange;
  final String gender;
  final String countries;
  final String colors;

  FilterItem(
      {this.color, this.dateRange, this.gender, this.countries, this.colors, this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration:
          BoxDecoration(color: isActive ? Color(0xFF333333) : Color(0xFF333333).withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
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

class CarDetail extends StatelessWidget {
  final String fullName;
  final String email;
  final String country;
  final String gender;
  final String jobTitle;
  final String bio;
  final String extras;

  CarDetail(
      {this.fullName,
      this.email,
      this.country,
      this.gender,
      this.jobTitle,
      this.bio,
      this.extras});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
          color: Color(0xFF333333), borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10.0),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Icon(
                      Icons.perm_identity,
                      color: Colors.white,
                      size: 22,
                    ),
                  )),
              SizedBox(
                width: 20,
              ),
             Expanded(
                 child:  Column(
                   mainAxisAlignment: MainAxisAlignment.start,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Text(
                         fullName,
                         style: kTextStyle.copyWith(
                             fontSize: 18, fontWeight: FontWeight.w800),
                       ),
                     ),
                     SizedBox(
                       height: 3.0,
                     ),
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Text(
                         jobTitle ?? '',
                         style: kTextStyle.copyWith(
                             fontSize: 14,
                             fontWeight: FontWeight.w800,
                             color: Colors.white.withOpacity(0.5)),
                       ),
                     )
                   ],
                 ),
             )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Marker(
                    text: gender,
                    icon: gender.toLowerCase() == 'male'
                        ? FontAwesomeIcons.mars
                        : FontAwesomeIcons.venus),
                SizedBox(
                  width: 20,
                ),
                Marker(text: country, icon: Icons.location_on),
                SizedBox(
                  width: 20,
                ),
                Marker(text: email, icon: Icons.mail_outline)
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Marker(
              text: extras,
              size: 15,
              icon: Icons.lightbulb_outline,
              color: Colors.white,
              style: kTextStyle.copyWith(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Marker(
              text: bio,
              icon: Icons.book,
              size: 15,
              color: Colors.white,
              style: kTextStyle.copyWith(color: Colors.white.withOpacity(0.5)),
            ),
          )
        ],
      ),
    );
  }
}

class Marker extends StatelessWidget {
  const Marker({this.text, this.icon, this.color, this.style, this.size});

  final String text;
  final IconData icon;
  final Color color;
  final TextStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: size ?? 20, color: color ?? Color(0XFF257ACF)),
        SizedBox(
          width: 10,
        ),
        Text(
          text,
          style: style ?? kTextStyle.copyWith(fontSize: 14),
        )
      ],
    );
  }
}

const kTextStyle = TextStyle(fontSize: 14, color: Colors.white);
