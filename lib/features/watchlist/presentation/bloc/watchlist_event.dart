part of 'watchlist_bloc.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlistEvent extends WatchlistEvent {
  const LoadWatchlistEvent();
}

class CreateWatchlistEvent extends WatchlistEvent {
  final String name;
  const CreateWatchlistEvent(this.name);
  @override List<Object?> get props => [name];
}

class RenameWatchlistEvent extends WatchlistEvent {
  final String folderId, name;
  const RenameWatchlistEvent(this.folderId, this.name);
  @override List<Object?> get props => [folderId, name];
}

class DeleteWatchlistEvent extends WatchlistEvent {
  final String folderId;
  const DeleteWatchlistEvent(this.folderId);
  @override List<Object?> get props => [folderId];
}

class ReorderWatchlistsEvent extends WatchlistEvent {
  final int oldIndex, newIndex;
  const ReorderWatchlistsEvent(this.oldIndex, this.newIndex);
  @override List<Object?> get props => [oldIndex, newIndex];
}

class AddSectionEvent extends WatchlistEvent {
  final String folderId, name;
  const AddSectionEvent(this.folderId, this.name);
  @override List<Object?> get props => [folderId, name];
}

class RenameSectionEvent extends WatchlistEvent {
  final String sectionId, name;
  const RenameSectionEvent(this.sectionId, this.name);
  @override List<Object?> get props => [sectionId, name];
}

class DeleteSectionEvent extends WatchlistEvent {
  final String sectionId;
  const DeleteSectionEvent(this.sectionId);
  @override List<Object?> get props => [sectionId];
}

class ToggleSectionCollapsed extends WatchlistEvent {
  final String sectionId;
  const ToggleSectionCollapsed(this.sectionId);
  @override List<Object?> get props => [sectionId];
}

class AddSymbolToSection extends WatchlistEvent {
  final String sectionId, symbol;
  const AddSymbolToSection(this.sectionId, this.symbol);
  @override List<Object?> get props => [sectionId, symbol];
}

class RemoveSymbolFromSection extends WatchlistEvent {
  final String sectionId, symbol;
  const RemoveSymbolFromSection(this.sectionId, this.symbol);
  @override List<Object?> get props => [sectionId, symbol];
}

class ReorderSymbolsInSection extends WatchlistEvent {
  final String sectionId;
  final int oldIndex, newIndex;
  const ReorderSymbolsInSection(this.sectionId, this.oldIndex, this.newIndex);
  @override List<Object?> get props => [sectionId, oldIndex, newIndex];
}

class MoveSymbolToSection extends WatchlistEvent {
  final String symbol, fromSectionId, toSectionId;
  const MoveSymbolToSection(this.symbol, this.fromSectionId, this.toSectionId);
  @override List<Object?> get props => [symbol, fromSectionId, toSectionId];
}

class SetActiveIndexEvent extends WatchlistEvent {
  final int index;
  const SetActiveIndexEvent(this.index);
  @override List<Object?> get props => [index];
}