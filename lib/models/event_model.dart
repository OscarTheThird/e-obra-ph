// models/event_model.dart
class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String organizerId;
  final List<String> participants;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.organizerId,
    required this.participants,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: DateTime.parse(map['date']),
      organizerId: map['organizerId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'organizerId': organizerId,
      'participants': participants,
    };
  }
}
