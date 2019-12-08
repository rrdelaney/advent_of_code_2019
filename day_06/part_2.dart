import 'dart:io';
import 'dart:convert';

class OrbitObject {
  final Set<OrbitObject> children = Set();
  OrbitObject parent;

  final String name;
  OrbitObject(this.name);
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
    outer.parent = inner;
  });

  var you = objectsByName['YOU'];
  final youPath = List<OrbitObject>();
  while (you != null) {
    youPath.add(you);
    you = you.parent;
  }

  var santa = objectsByName['SAN'];
  final santaPath = List<OrbitObject>();
  while (santa != null) {
    santaPath.add(santa);
    santa = santa.parent;
  }

  var steps = youPath.length + santaPath.length;
  for (var i = 0; i < youPath.length; ++i) {
    for (var j = 0; j < santaPath.length; ++j) {
      if (youPath[i] == santaPath[j] && i + j < steps) {
        steps = i + j;
      }
    }
  }

  print(steps - 2);
}
