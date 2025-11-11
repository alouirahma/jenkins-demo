// lib/Services/event_service.dart
import 'dart:convert';
import 'package:mobile2025/Entites/event.dart';
import 'package:mobile2025/Services/database_helper.dart';

class EventService {
  final DatabaseHelper _db = DatabaseHelper();

  // Récupérer tous les événements à venir
  Future<List<Event>> getUpcomingEvents() async {
    final data = await _db.getUpcomingEvents();
    return data.map((map) => Event.fromMap(_safeCastMap(map))).toList();
  }

  // Récupérer un événement par ID
  Future<Event?> getEventById(String id) async {
    final db = await _db.database;
    final result = await db.query(
      DatabaseHelper.tableEvents,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Event.fromMap(_safeCastMap(result.first)) : null;
  }

  // Créer un événement
  Future<void> createEvent(Event event) async {
    await _db.insert(DatabaseHelper.tableEvents, event.toMap());
  }

  // Mettre à jour un événement
  Future<void> updateEvent(Event event) async {
    await _db.update(DatabaseHelper.tableEvents, event.toMap(), event.id);
  }

  // Supprimer un événement
  Future<void> deleteEvent(String id) async {
    await _db.delete(DatabaseHelper.tableEvents, id);
  }

  // S'inscrire à un événement
  Future<void> registerToEvent(String eventId, String userId) async {
    await _db.registerUserToEvent(eventId, userId);
  }

  // Se désinscrire
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    final db = await _db.database;
    final event = await db.query(
      DatabaseHelper.tableEvents,
      where: 'id = ?',
      whereArgs: [eventId],
    );

    if (event.isNotEmpty) {
      final usersJson = event.first['registeredUsers'] as String? ?? '[]';
      final List<String> users = List<String>.from(jsonDecode(usersJson));
      users.remove(userId);

      await _db.update(
        DatabaseHelper.tableEvents,
        {'registeredUsers': jsonEncode(users)},
        eventId,
      );
    }
  }

  // Vérifier inscription
  Future<bool> isUserRegistered(String eventId, String userId) async {
    final event = await getEventById(eventId);
    return event?.registeredUsers.contains(userId) ?? false;
  }

  // Événements par contenu
  Future<List<Event>> getEventsByContent(String contentId) async {
    final db = await _db.database;
    final result = await db.query(
      DatabaseHelper.tableEvents,
      where: 'contentId = ?',
      whereArgs: [contentId],
    );
    return result.map((map) => Event.fromMap(_safeCastMap(map))).toList();
  }

  // RECOMMENDATIONS IA
  Future<List<Event>> getRecommendedEvents(String userId) async {
    final db = await _db.database;

    // Récupérer les genres préférés de l'utilisateur
    final userResult = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (userResult.isEmpty) return [];

    final favoriteGenresJson = userResult.first['favoriteGenres'] as String? ?? '[]';
    final List<String> favoriteGenres = List<String>.from(jsonDecode(favoriteGenresJson));

    // Récupérer les événements à venir
    final today = DateTime.now().toIso8601String().split('T')[0];
    final allEventsResult = await db.query(
      DatabaseHelper.tableEvents,
      where: 'date >= ?',
      whereArgs: [today],
    );

    final events = allEventsResult
        .map((map) => Event.fromMap(_safeCastMap(map)))
        .toList();

    // Calcul du score
    events.sort((a, b) {
      final scoreA = _calculateScore(a, favoriteGenres);
      final scoreB = _calculateScore(b, favoriteGenres);
      return scoreB.compareTo(scoreA); // Descendant
    });

    return events.take(5).toList();
  }

  // Score intelligent
  int _calculateScore(Event event, List<String> userGenres) {
    int score = 0;

    // Tags correspondants
    if (event.tags != null) {
      for (final tag in event.tags!) {
        if (userGenres.contains(tag)) score += 20;
      }
    }

    // Live en cours
    if (event.isLiveNow()) score += 30;

    // Populaire
    if (event.registeredUsers.length > 10) score += 10;

    // Proche dans le temps
    final daysUntil = DateTime.parse(event.date).difference(DateTime.now()).inDays;
    if (daysUntil <= 3) score += 15;

    return score;
  }

  // CAST SÉCURISÉ (évite l'erreur Object → String)
  Map<String, dynamic> _safeCastMap(Map<String, dynamic> map) {
    return {
      'id': map['id'] as String,
      'title': map['title'] as String,
      'date': map['date'] as String,
      'time': map['time'] as String?,
      'location': map['location'] as String?,
      'link': map['link'] as String?,
      'image': map['image'] as String?,
      'videoUrl': map['videoUrl'] as String?,
      'contentId': map['contentId'] as String?,
      'description': map['description'] as String?,
      'registeredUsers': map['registeredUsers'] != null
          ? List<String>.from(jsonDecode(map['registeredUsers'] as String))
          : <String>[],
      'tags': map['tags'] != null
          ? List<String>.from(jsonDecode(map['tags'] as String))
          : null,
    };
  }
}