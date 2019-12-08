import 'dart:io';
import 'dart:convert';

class OrbitObject {
  final Set<OrbitObject> children = Set();
  final String name;
  OrbitObject(this.name);

  int totalOrbits = 0;
}

void main() async {
  final objectsByName = Map<String, OrbitObject>();
  await stdin.transform(utf8.decoder).transform(LineSplitter()).forEach((line) {
    final pair = line.split(")");
    final inner = objectsByName.putIfAbsent(pair[0], () {
      return OrbitObject(pair[0]);
    });

    final outer = objectsByName.putIfAbsent(pair[1], () {
      return OrbitObject(pair[1]);
    });

    inner.children.add(outer);
  });

  final com = objectsByName['COM'];
  var depth = 0;
  var current = Set<OrbitObject>.from([com]);
  while (current.length > 0) {
    for (final obj in current) {
      obj.totalOrbits = depth;
    }

    depth += 1;
    current = Set.from(current.expand((obj) => obj.children));
  }

  final totalOrbits = objectsByName.values
      .map((obj) => obj.totalOrbits)
      .reduce((a, b) => a + b);

  print(totalOrbits);
}
