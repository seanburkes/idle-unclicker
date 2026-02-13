import '../events/character_events.dart';

/// Base class for all aggregate roots
/// Provides domain event handling capabilities
abstract class AggregateRoot {
  final List<DomainEvent> _domainEvents = [];

  /// Records a domain event
  void recordEvent(DomainEvent event) {
    _domainEvents.add(event);
  }

  /// Gets all uncommitted domain events
  List<DomainEvent> getDomainEvents() => List.unmodifiable(_domainEvents);

  /// Clears all domain events (called after persistence)
  void clearDomainEvents() {
    _domainEvents.clear();
  }

  /// Checks if there are any pending events
  bool get hasPendingEvents => _domainEvents.isNotEmpty;
}
