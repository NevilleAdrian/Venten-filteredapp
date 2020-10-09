class Car {
 int id;
 String first_name;
 String last_name;
 String email;
 String country;
 String car_model;
 int car_model_year;
 String car_color;
 String gender;
 String job_title;
 String bio;

 Car({
   this.id,
   this.first_name,
   this.last_name,
   this.email,
   this.country,
   this.car_model,
   this.car_model_year,
   this.car_color,
   this.gender,
   this.job_title,
   this.bio
});

List<Car> createCars (dynamic item) {
  var data = item as List;
  List<Car> cars = List<Car>();
  for(int i = 1; i < data.length; i++){
    var newItems = data[i];
    cars.add(Car(
      id: newItems[0],
      first_name: newItems[1],
      last_name: newItems[2],
      email: newItems[3],
      country: newItems[4],
      car_model: newItems[5],
      car_model_year: newItems[6],
      car_color: newItems[7],
      gender: newItems[8],
      job_title: newItems[9],
      bio: newItems[10],
    ));
  }
  return cars;
}
}
