// Класс для хранения информации о точке останова
class Breakpoint {
  final String name;
  final String description;
  final Duration position;

  Breakpoint({
    required this.name,
    required this.description,
    required this.position,
  });

  // Метод для создания копии объекта с измененными параметрами
  Breakpoint copyWith({
    String? name,
    String? description,
    Duration? position,
  }) {
    return Breakpoint(
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
    );
  }
}
