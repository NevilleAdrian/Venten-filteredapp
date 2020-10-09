// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:filteredapp/components/home.dart';
import 'package:filteredapp/models/Cars.dart';
import 'package:filteredapp/models/Filtercar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Check length of filter and verify first name', () {
    final cars = [
      Car(id: 1, first_name: 'Neville', last_name: 'Chukumah', car_model: 'Suzuki', car_color: 'red', car_model_year: 2000, country: 'Nigeria', email: 'neville.chukumah@gmail.com', job_title: 'Flutter Developer', gender: 'Male', bio: 'pushing strong')];
    final filter = FilterCar(id: 1, startYear: 1990, endYear: 2005, gender: 'male', countries: ['Nigeria', 'USA'], colors: ['red', 'green']);
    final result = onFilter(filter, cars);
    expect(result.length, 1);
    expect(result.first.first_name, 'Neville');
  });
}
