import 'dart:io';

Iterable<String> pointsInPath(String path) sync* {
  final instructions = path.split(",");

  var x = 0;
  var y = 0;
  for (final instruction in instructions) {
    final dir = instruction[0];
    final len = int.parse(instruction.substring(1));

    for (var i = 0; i < len; ++i) {
      switch (dir) {
        case "U":
          y += 1;
          break;
        case "D":
          y -= 1;
          break;
        case "L":
          x -= 1;
          break;
        case "R":
          x += 1;
          break;
      }

      yield "$x:$y";
    }
  }
}

void main() {
  final pathA = stdin.readLineSync();
  final pathB = stdin.readLineSync();

  final pointsInPathA = Set<String>();
  final intersections = Set<String>();

  for (final point in pointsInPath(pathA)) {
    pointsInPathA.add(point);
  }

  for (final point in pointsInPath(pathB)) {
    if (pointsInPathA.contains(point)) {
      intersections.add(point);
    }
  }

  final intersectionLens = intersections.map((p) {
    return p
        .split(":")
        .map(int.parse)
        .map((f) => f.abs())
        .reduce((a, b) => a + b);
  }).toList();

  intersectionLens.sort();
  print(intersectionLens.first);
}
