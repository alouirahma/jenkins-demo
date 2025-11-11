// lib/Entites/event.dart
import 'dart:convert';

class Event {
  final String id;
  final String title;
  final String date;
  final String? time;
  final String? location;
  final String? link;
  final String? image;
  final String? videoUrl;        // NOUVEAU
  final String? contentId;
  final String? description;
  final List<String> registeredUsers;
 final List<String>? tags;
  Event({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.location,
    this.link,
    this.image,
    this.videoUrl,              // NOUVEAU
    this.contentId,
    this.description,
    this.tags,
    List<String>? registeredUsers,
  }) : registeredUsers = registeredUsers ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'link': link,
      'image': image,
      'videoUrl': videoUrl,      // NOUVEAU
      'contentId': contentId,
      'description': description,
      'registeredUsers': registeredUsers.isNotEmpty
          ? jsonEncode(registeredUsers)
          : jsonEncode([]),
      'tags': tags != null ? jsonEncode(tags) : null,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      time: map['time'] as String?,
      location: map['location'] as String?,
      link: map['link'] as String?,
      image: map['image'] as String?,
      videoUrl: map['videoUrl'] as String?,  // NOUVEAU
      contentId: map['contentId'] as String?,
      description: map['description'] as String?,
      registeredUsers: map['registeredUsers'] != null
          ? List<String>.from(jsonDecode(map['registeredUsers'] as String))
          : [],
          tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : null,
    );
  }
}

// EXTENSION CORRIGÉE : à l'extérieur de la classe, une seule fois
extension EventExtension on Event {
  bool isLiveNow() {
    try {
      final now = DateTime.now();
      final eventDate = DateTime.parse(date);

      if (time != null && time!.trim().isNotEmpty) {
        final timeParts = time!.trim().split(':');
        final hour = int.parse(timeParts[0]);
        final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

        final eventDateTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          hour,
          minute,
        );

        final diff = eventDateTime.difference(now).inMinutes.abs();
        return diff <= 15; // ±15 minutes
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}