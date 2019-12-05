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

  final pointsInPathA = Map<String, int>();
  final intersections = Map<String, int>();

  var step = 0;
  for (final point in pointsInPath(pathA)) {
    step += 1;
    pointsInPathA[point] = step;
  }

  step = 0;
  for (final point in pointsInPath(pathB)) {
    step += 1;
    if (pointsInPathA.containsKey(point)) {
      intersections[point] = step + pointsInPathA[point];
    }
  }

  final intersectionLens = intersections.values.toList();
  intersectionLens.sort();
  print(intersectionLens.first);
}
