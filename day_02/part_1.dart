import 'dart:io';

void runProgram(List<int> program) {
  for (var position = 0; position < program.length; position += 4) {
    final opcode = program[position];
    if (opcode == 99) {
      break;
    }

    final a = program[program[position + 1]];
    final b = program[program[position + 2]];
    final output = program[position + 3];
    if (opcode == 1) {
      program[output] = a + b;
    } else if (opcode == 2) {
      program[output] = a * b;
    }
  }
}

void main() {
  final input = stdin.readLineSync();
  final program = input.split(",").map(int.parse).toList();
  program[1] = 12;
  program[2] = 2;
  runProgram(program);
  print(program[0]);
}
