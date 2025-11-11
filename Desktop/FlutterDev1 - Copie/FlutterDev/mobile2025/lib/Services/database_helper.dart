import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // --- Singleton ---
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // --- Configuration ---
  static const String _dbName = 'mobile2025.db';
  static const int _dbVersion = 3; // Version 3 : videoUrl + tags

  // --- Table Names ---
  static const String tableContents = 'contents';
  static const String tableUsers = 'users';
  static const String tableFavorites = 'favorites';
  static const String tableReviews = 'reviews';
  static const String tableEvents = 'events';

  // --- Accès à la base ---
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // --- Initialisation ---
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // --- Création des tables ---
  Future<void> _onCreate(Database db, int version) async {
    // Table Contenu
    await db.execute('''
      CREATE TABLE $tableContents (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL CHECK (type IN ('audio', 'video', 'podcast')),
        title TEXT NOT NULL,
        artist TEXT,
        duration INTEGER,
        url TEXT,
        coverUrl TEXT,
        genre TEXT,
        tags TEXT,
        uploadedBy TEXT,
        uploadDate TEXT,
        views INTEGER DEFAULT 0,
        likes INTEGER DEFAULT 0,
        isPublic INTEGER DEFAULT 1
      )
    ''');

    // Table Utilisateurs
    await db.execute('''
      CREATE TABLE $tableUsers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        avatar TEXT,
        bio TEXT,
        favoriteGenres TEXT,
        isPremium INTEGER DEFAULT 0
      )
    ''');

    // Table Favoris
    await db.execute('''
      CREATE TABLE $tableFavorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        contentId TEXT NOT NULL,
        playlist TEXT,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES $tableUsers(id) ON DELETE CASCADE,
        FOREIGN KEY (contentId) REFERENCES $tableContents(id) ON DELETE CASCADE,
        UNIQUE(userId, contentId, playlist)
      )
    ''');

    // Table Avis
    await db.execute('''
      CREATE TABLE $tableReviews (
        id TEXT PRIMARY KEY,
        contentId TEXT NOT NULL,
        userId TEXT NOT NULL,
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment TEXT,
        date TEXT NOT NULL,
        isApproved INTEGER DEFAULT 1,
        FOREIGN KEY (contentId) REFERENCES $tableContents(id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES $tableUsers(id) ON DELETE CASCADE
      )
    ''');

    // Table Événements (videoUrl + tags)
    await db.execute('''
      CREATE TABLE $tableEvents (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT,
        location TEXT,
        link TEXT,
        image TEXT,
        videoUrl TEXT,
        contentId TEXT,
        description TEXT,
        registeredUsers TEXT,
        tags TEXT,  -- NOUVEAU
        FOREIGN KEY (contentId) REFERENCES $tableContents(id) ON DELETE SET NULL
      )
    ''');

    await _insertMockData(db);
  }

  // --- MIGRATION ---
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableEvents ADD COLUMN videoUrl TEXT');
      print('Migration v2: videoUrl ajouté');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $tableEvents ADD COLUMN tags TEXT');
      print('Migration v3: tags ajouté à events');
    }
  }

  // --- Données mock ---
  Future<void> _insertMockData(Database db) async {
    // Contenu
    await db.insert(tableContents, {
      'id': 'c1', 'type': 'audio', 'title': 'Shape of You', 'artist': 'Ed Sheeran',
      'duration': 235, 'url': 'https://example.com/audio.mp3',
      'coverUrl': 'https://example.com/cover.jpg', 'genre': 'Pop',
      'tags': jsonEncode(['pop', 'hit']), 'uploadedBy': 'admin',
      'uploadDate': '2025-01-01', 'views': 1000, 'likes': 500, 'isPublic': 1
    });

    // Utilisateur
    await db.insert(tableUsers, {
      'id': 'u1', 'name': 'Alice', 'email': 'alice@example.com',
      'avatar': 'https://i.pravatar.cc/150?img=1', 'bio': 'Fan de musique',
      'favoriteGenres': jsonEncode(['Pop', 'Dance']), 'isPremium': 1
    });

    // Favoris
    await db.insert(tableFavorites, {
      'userId': 'u1', 'contentId': 'c1', 'playlist': 'Mes Favoris', 'addedAt': '2025-01-02'
    });

    // Avis
    await db.insert(tableReviews, {
      'id': 'r1', 'contentId': 'c1', 'userId': 'u1', 'rating': 5,
      'comment': 'Super !', 'date': '2025-01-03', 'isApproved': 1
    });

    // Événement avec vidéo + tags
    await db.insert(tableEvents, {
      'id': 'e1',
      'title': 'LIVE TEST - DJ Snake',
      'date': '2025-11-15',
      'time': '20:00',
      'location': 'Online',
      'link': 'https://twitch.tv/djsnake',
      'image': 'https://example.com/event.jpg',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'contentId': 'c1',
      'description': 'Concert live en direct !',
      'registeredUsers': jsonEncode(['u1']),
      'tags': jsonEncode(['Live', 'DJ', 'Dance', 'Premium'])  // TAGS
    });

    // Autre événement
    await db.insert(tableEvents, {
      'id': 'e2',
      'title': 'Concert Gratuit - Pop Night',
      'date': '2025-11-20',
      'time': '19:30',
      'location': 'Paris',
      'image': 'https://example.com/pop.jpg',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'tags': jsonEncode(['Concert', 'Gratuit', 'Pop']),
      'registeredUsers': jsonEncode([])
    });
  }

  // ==================== MÉTHODES MODULE 1 : GESTION CONTENU ====================
  Future<List<Map<String, dynamic>>> getPublicContents() async {
    final db = await database;
    return db.query(tableContents, where: 'isPublic = ?', whereArgs: [1]);
  }

  Future<void> addContent(Map<String, dynamic> data) async {
    await insert(tableContents, data);
  }

  // ==================== MÉTHODES MODULE 2 : FAVORIS ====================
  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    final db = await database;
    return db.query(tableFavorites, where: 'userId = ?', whereArgs: [userId]);
  }

  Future<bool> toggleFavorite(String userId, String contentId, String? playlist) async {
    final db = await database;
    final exists = await db.query(
      tableFavorites,
      where: 'userId = ? AND contentId = ?',
      whereArgs: [userId, contentId],
    );
    if (exists.isNotEmpty) {
      await db.delete(
        tableFavorites,
        where: 'userId = ? AND contentId = ?',
        whereArgs: [userId, contentId],
      );
      return false;
    } else {
      await insert(tableFavorites, {
        'userId': userId,
        'contentId': contentId,
        'playlist': playlist ?? 'Default',
        'addedAt': DateTime.now().toIso8601String(),
      });
      return true;
    }
  }

  // ==================== MÉTHODES MODULE 3 : UTILISATEUR ====================
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(tableUsers, where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? result.first : null;
  }

  // ==================== MÉTHODES MODULE 4 : AVIS ====================
  Future<List<Map<String, dynamic>>> getContentReviews(String contentId) async {
    final db = await database;
    return db.query(
      tableReviews,
      where: 'contentId = ? AND isApproved = ?',
      whereArgs: [contentId, 1],
    );
  }

  Future<double> getAverageRating(String contentId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avg FROM $tableReviews WHERE contentId = ?',
      [contentId],
    );
    return result.first['avg'] as double? ?? 0.0;
  }

  // ==================== MÉTHODES MODULE 5 : ÉVÉNEMENTS ====================
  Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return db.query(
      tableEvents,
      where: 'date >= ?',
      whereArgs: [today],
      orderBy: 'date ASC',
    );
  }

  Future<void> registerUserToEvent(String eventId, String userId) async {
    final db = await database;
    final event = await db.query(tableEvents, where: 'id = ?', whereArgs: [eventId]);
    if (event.isNotEmpty) {
      List<String> users = List<String>.from(
        jsonDecode(event.first['registeredUsers'] as String? ?? '[]'),
      );
      if (!users.contains(userId)) {
        users.add(userId);
        await update(tableEvents, {'registeredUsers': jsonEncode(users)}, eventId);
      }
    }
  }

  // ==================== MÉTHODES GÉNÉRIQUES ====================
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}