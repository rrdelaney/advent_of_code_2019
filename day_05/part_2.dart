import 'dart:collection';
import 'dart:io';
import 'dart:math';

Iterable<int> digits(int num) sync* {
  int numDigits = (log(num) / log(10)).floor() + 1;
  for (var i = numDigits; i > 0; i--) {
    yield (num.remainder(pow(10, i)) / pow(10, i - 1)).floor();
  }
}

String printMemory(List<int> memory, int start, int length) {
  return "[" + memory.sublist(start, start + length + 1).join(" | ") + "]";
}

class Params {
  final int position;
  final List<int> modes;
  final List<int> memory;

  const Params(this.memory, this.position, this.modes);

  int read(int paramNum) {
    final raw = memory[position + paramNum + 1];
    final mode = modes[paramNum];
    if (mode == 0 && (raw < 0 || raw > memory.length)) {
      throw new ArgumentError(
          "Could not read value at position $raw from instruction ${printMemory(memory, position, modes.length + 1)}");
    }

    if (mode == 0) {
      return memory[raw];
    } else {
      return raw;
    }
  }

  void write(int paramNum, int value) {
    final raw = memory[position + paramNum + 1];
    memory[raw] = value;
  }
}

class OpIO {
  final outs = Queue<int>();
  Queue<int> ins;

  OpIO(Iterable<int> inStream) {
    ins = Queue.from(inStream);
  }

  int read() {
    return ins.removeFirst();
  }

  void write(int value) {
    outs.add(value);
  }

  List<int> flush() {
    return outs.toList();
  }
}

enum OpStatusValue {
  ok,
  jump,
  halt,
}

class OpStatus {
  OpStatusValue value;
  int jumpPosition;

  OpStatus.ok() {
    value = OpStatusValue.ok;
  }

  OpStatus.halt() {
    value = OpStatusValue.halt;
  }

  OpStatus.jump(this.jumpPosition) {
    value = OpStatusValue.jump;
  }
}

abstract class Op {
  static final code = 0;
  final int numParams = 0;
  OpStatus apply(Params params, OpIO io);
}

class AddOp extends Op {
  static final int code = 1;
  final int numParams = 3;
  OpStatus apply(Params params, OpIO io) {
    final a = params.read(0);
    final b = params.read(1);
    params.write(2, a + b);
    return OpStatus.ok();
  }
}

class MultOp extends Op {
  static final int code = 2;
  final int numParams = 3;
  OpStatus apply(Params params, OpIO io) {
    final a = params.read(0);
    final b = params.read(1);
    params.write(2, a * b);
    return OpStatus.ok();
  }
}

class ReadOp extends Op {
  static final int code = 3;
  final int numParams = 1;
  OpStatus apply(Params params, OpIO io) {
    params.write(0, io.read());
    return OpStatus.ok();
  }
}

class WriteOp extends Op {
  static final int code = 4;
  final int numParams = 1;
  OpStatus apply(Params params, OpIO io) {
    io.write(params.read(0));
    return OpStatus.ok();
  }
}

class JumpIfTrueOp extends Op {
  static final int code = 5;
  final int numParams = 2;
  OpStatus apply(Params params, OpIO io) {
    final test = params.read(0);
    final jumpTo = params.read(1);
    if (test != 0) {
      return OpStatus.jump(jumpTo);
    } else {
      return OpStatus.ok();
    }
  }
}

class JumpIfFalseOp extends Op {
  static final int code = 6;
  final int numParams = 2;
  OpStatus apply(Params params, OpIO io) {
    final test = params.read(0);
    final jumpTo = params.read(1);
    if (test == 0) {
      return OpStatus.jump(jumpTo);
    } else {
      return OpStatus.ok();
    }
  }
}

class LessThanOp extends Op {
  static final int code = 7;
  final int numParams = 3;
  OpStatus apply(Params params, OpIO io) {
    final a = params.read(0);
    final b = params.read(1);
    if (a < b) {
      params.write(2, 1);
    } else {
      params.write(2, 0);
    }

    return OpStatus.ok();
  }
}

class EqualsOp extends Op {
  static final int code = 8;
  final int numParams = 3;
  OpStatus apply(Params params, OpIO io) {
    final a = params.read(0);
    final b = params.read(1);
    if (a == b) {
      params.write(2, 1);
    } else {
      params.write(2, 0);
    }

    return OpStatus.ok();
  }
}

class HaltOp extends Op {
  static final int code = 99;
  final int numParams = 0;
  OpStatus apply(Params params, OpIO io) {
    return OpStatus.halt();
  }
}

class OpCode {
  int raw;
  List<int> memory;
  int position;

  Op operation;
  Params params;

  OpCode(this.memory, this.position) {
    raw = memory[position];
    final ds = digits(raw).toList();
    while (ds.length < 2) {
      ds.insert(0, 0);
    }

    final code0 = ds.removeLast();
    final code1 = ds.removeLast();
    final code = (10 * code1) + code0;
    operation = operationFor(code);

    final numParams = operation.numParams;
    while (ds.length < numParams) {
      ds.insert(0, 0);
    }

    params = Params(memory, position, ds.reversed.toList());
  }

  Op operationFor(int code) {
    if (code == AddOp.code) return AddOp();
    if (code == MultOp.code) return MultOp();
    if (code == ReadOp.code) return ReadOp();
    if (code == WriteOp.code) return WriteOp();
    if (code == JumpIfTrueOp.code) return JumpIfTrueOp();
    if (code == JumpIfFalseOp.code) return JumpIfFalseOp();
    if (code == LessThanOp.code) return LessThanOp();
    if (code == EqualsOp.code) return EqualsOp();
    if (code == HaltOp.code) return HaltOp();
    throw ArgumentError("No operation for code $code");
  }

  bool wasUpdated() {
    return raw != memory[position];
  }
}

class Program {
  List<int> memory;
  OpIO io;

  Program(String raw, Iterable<int> ins) {
    memory = raw.split(",").map(int.parse).toList();
    io = OpIO(ins);
  }

  OpCode opCodeAt(int position) {
    return OpCode(memory, position);
  }

  OpStatus runOpCode(OpCode opcode) {
    return opcode.operation.apply(opcode.params, io);
  }
}

void runProgram(Program program) {
  var position = 0;

  runLoop:
  while (true) {
    final opcode = program.opCodeAt(position);
    final status = program.runOpCode(opcode);
    switch (status.value) {
      case OpStatusValue.ok:
        break;
      case OpStatusValue.halt:
        break runLoop;
      case OpStatusValue.jump:
        position = status.jumpPosition;
        break;
    }

    if (status.value != OpStatusValue.jump && !opcode.wasUpdated()) {
      position += 1 + opcode.operation.numParams;
    }
  }
}

void main() {
  final input = stdin.readLineSync();
  final program = Program(input, [5]);
  runProgram(program);
  print(program.io.flush());
}
