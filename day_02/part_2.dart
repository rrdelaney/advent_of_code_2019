import 'dart:io';

enum OpStatus {
  ok,
  halt,
}

typedef OpApply = OpStatus Function(List<int> program, List<int> params);

class Op {
  final int params;
  final OpApply apply;
  const Op(this.params, this.apply);
}

OpStatus applyAdd(List<int> program, List<int> params) {
  final a = program[params[0]];
  final b = program[params[1]];
  final output = params[2];
  program[output] = a + b;
  return OpStatus.ok;
}

OpStatus applyMult(List<int> program, List<int> params) {
  final a = program[params[0]];
  final b = program[params[1]];
  final output = params[2];
  program[output] = a * b;
  return OpStatus.ok;
}

OpStatus applyHalt(List<int> program, List<int> params) {
  return OpStatus.halt;
}

const operations = {
  1: Op(3, applyAdd),
  2: Op(3, applyMult),
  99: Op(0, applyHalt),
};

int runProgram(List<int> program) {
  var mem = List.of(program);
  var position = 0;

  runLoop:
  while (true) {
    final opcode = mem[position];
    if (!operations.containsKey(opcode)) {
      break;
    }

    final op = operations[opcode];
    final params = mem.sublist(position + 1, position + 1 + op.params);
    final status = op.apply(mem, params);
    switch (status) {
      case OpStatus.ok:
        break;
      case OpStatus.halt:
        break runLoop;
    }

    position += 1 + op.params;
  }

  return mem[0];
}

void main() {
  final input = stdin.readLineSync();
  final program = input.split(",").map(int.parse).toList();
  for (var noun = 0; noun <= 99; noun += 1) {
    for (var verb = 0; verb <= 99; verb += 1) {
      program[1] = noun;
      program[2] = verb;
      try {
        final output = runProgram(program);
        if (output == 19690720) {
          print((100 * noun) + verb);
        }
      } on RangeError {}
    }
  }
}
