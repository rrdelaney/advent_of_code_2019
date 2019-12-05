import 'dart:io';
import 'dart:math';

Iterable<int> digits(int num) sync* {
  int numDigits = (log(num) / log(10)).floor() + 1;
  for (var i = numDigits; i > 0; i--) {
    yield (num.remainder(pow(10, i)) / pow(10, i - 1)).floor();
  }
}

class DigitPair {
  final int left, right;
  DigitPair(this.left, this.right);
}

Iterable<DigitPair> digitsWithNext(int num) sync* {
  int prev = null;
  for (var d in digits(num)) {
    if (prev == null) {
      prev = d;
    } else {
      yield DigitPair(prev, d);
      prev = d;
    }
  }
}

void main() {
  final range = stdin.readLineSync().split("-").map(int.parse).toList();
  final low = range[0];
  final high = range[1];

  var matchCount = 0;

  suspectLoop:
  for (var suspect = low; suspect < high; suspect += 1) {
    var hasDouble = false;
    for (var pair in digitsWithNext(suspect)) {
      if (pair.left == pair.right) hasDouble = true;
      if (pair.left > pair.right) continue suspectLoop;
    }

    if (hasDouble == false) continue;
    matchCount += 1;
  }

  print(matchCount);
}
