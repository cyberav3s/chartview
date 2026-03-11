import 'package:equatable/equatable.dart';

class ListSection extends Equatable {
  final String id;
  final String name;
  final List<String> symbols;
  final bool collapsed;

  const ListSection({
    required this.id,
    required this.name,
    required this.symbols,
    this.collapsed = false,
  });

  ListSection copyWith({
    String? name,
    List<String>? symbols,
    bool? collapsed,
  }) => ListSection(
    id: id,
    name: name ?? this.name,
    symbols: symbols ?? this.symbols,
    collapsed: collapsed ?? this.collapsed,
  );

  @override
  List<Object?> get props => [id, name, symbols, collapsed];
}

class Watchlist extends Equatable {
  final String id;
  final String name;
  final List<ListSection> sections;

  const Watchlist({
    required this.id,
    required this.name,
    required this.sections,
  });

  List<String> get allSymbols => sections.expand((s) => s.symbols).toList();

  Watchlist copyWith({String? name, List<ListSection>? sections}) =>
      Watchlist(id: id, name: name ?? this.name, sections: sections ?? this.sections);

  @override
  List<Object?> get props => [id, name, sections];
}
