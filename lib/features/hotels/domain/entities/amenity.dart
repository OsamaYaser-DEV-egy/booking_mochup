/// The facility groups a property is described by.
///
/// The `id` is the stable key stored in Firestore and used by filters, so
/// renaming a label never breaks stored data.
enum Amenity {
  freeWifi('free_wifi', 'Free WiFi'),
  parking('parking', 'Parking'),
  swimmingPool('swimming_pool', 'Swimming pool'),
  airportShuttle('airport_shuttle', 'Airport shuttle'),
  familyRooms('family_rooms', 'Family rooms'),
  nonSmokingRooms('non_smoking_rooms', 'Non-smoking rooms'),
  restaurant('restaurant', 'Restaurant'),
  roomService('room_service', 'Room service'),
  frontDesk24h('front_desk_24h', '24-hour front desk'),
  fitnessCentre('fitness_centre', 'Fitness centre'),
  spa('spa', 'Spa and wellness centre'),
  bar('bar', 'Bar'),
  airConditioning('air_conditioning', 'Air conditioning'),
  breakfast('breakfast', 'Breakfast'),
  beachfront('beachfront', 'Beachfront'),
  terrace('terrace', 'Terrace'),
  petsAllowed('pets_allowed', 'Pets allowed'),
  facilitiesForDisabled(
    'facilities_for_disabled',
    'Facilities for disabled guests',
  ),
  laundry('laundry', 'Laundry'),
  teaCoffeeMaker('tea_coffee_maker', 'Tea/coffee maker');

  const Amenity(this.id, this.label);

  final String id;
  final String label;

  static Amenity? fromId(String id) {
    for (final amenity in Amenity.values) {
      if (amenity.id == id) return amenity;
    }
    return null;
  }
}
