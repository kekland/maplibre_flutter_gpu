import 'dart:math';

int _parameterInteger(int v) => ((v >> 1) ^ (-(v & 1)));

void withCursorPoint(
  List<Command> geometry,
  void Function(Command command, Point<int> point) callback,
) {
  var cursorPoint = Point(0, 0);

  for (final command in geometry) {
    if (command is MoveToCommand) {
      cursorPoint += command.point;
    } else if (command is LineToCommand) {
      cursorPoint += command.point;
    }

    callback(command, cursorPoint);
  }
}

List<Command> parseGeometry(List<int> geometry) {
  final commands = <Command>[];
  if (geometry.isEmpty) return commands;

  var i = 0;
  while (i < geometry.length) {
    final value = geometry[i];

    final id = value & 0x7;
    final count = value >> 3;

    i += 1;
    for (var j = 0; j < count; j++) {
      if (id == 1) {
        commands.add(
          MoveToCommand(
            _parameterInteger(geometry[i]),
            _parameterInteger(geometry[i + 1]),
          ),
        );

        i += 2;
      } else if (id == 2) {
        commands.add(
          LineToCommand(
            _parameterInteger(geometry[i]),
            _parameterInteger(geometry[i + 1]),
          ),
        );

        i += 2;
      } else if (id == 7) {
        commands.add(ClosePathCommand());
      } else {
        throw Exception('Unknown command ID: $id');
      }
    }
  }

  return commands;
}

class Command {
  const Command();
}

class MoveToCommand extends Command {
  MoveToCommand(int param1, int param2) : point = Point(param1, param2);

  final Point<int> point;
}

class LineToCommand extends Command {
  LineToCommand(int param1, int param2) : point = Point(param1, param2);

  final Point<int> point;
}

class ClosePathCommand extends Command {
  const ClosePathCommand();
}
