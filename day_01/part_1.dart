import 'dart:io';
import 'dart:convert';

int fuelForMass(int mass) => (mass / 3).floor() - 2;

void main() {
  stdin
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .map(int.parse)
      .map(fuelForMass)
      .reduce((a, b) => a + b)
      .then(print);
}
