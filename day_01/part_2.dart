import 'dart:io';
import 'dart:convert';

int fuelForMass(int mass) => (mass / 3).floor() - 2;

int additionalFuel(int fuelMass) {
  final additional = fuelForMass(fuelMass);
  if (additional > 0) {
    return additional + additionalFuel(additional);
  } else {
    return 0;
  }
}

void main() {
  stdin
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .map(int.parse)
      .map(fuelForMass)
      .map((mass) => mass + additionalFuel(mass))
      .reduce((a, b) => a + b)
      .then(print);
}
