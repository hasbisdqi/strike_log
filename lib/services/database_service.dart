import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/catch_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('strikelog.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE catches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fishSpecies TEXT NOT NULL,
        weight REAL NOT NULL,
        length REAL NOT NULL,
        bait TEXT NOT NULL,
        locationName TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp TEXT NOT NULL,
        imagePath TEXT,
        txHash TEXT
      )
    ''');
    
    // Seed dummy data
    await db.insert('catches', {
      'fishSpecies': 'Ikan Kakap Merah (Red Snapper)',
      'weight': 3.4,
      'length': 52.0,
      'bait': 'Udang Hidup',
      'locationName': 'Dermaga Pantai Sadeng, Gunungkidul',
      'latitude': -8.1908,
      'longitude': 110.8017,
      'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'imagePath': null,
      'txHash': '5UfD...9xKm'
    });
    await db.insert('catches', {
      'fishSpecies': 'Ikan Nila Super',
      'weight': 1.2,
      'length': 28.5,
      'bait': 'Pelet Cacing',
      'locationName': 'Waduk Sermo, Kulon Progo',
      'latitude': -7.8286,
      'longitude': 110.1219,
      'timestamp': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'imagePath': null,
      'txHash': '8Lk2...4mPz'
    });
  }

  Future<int> insertCatch(CatchLog item) async {
    final db = await instance.database;
    return await db.insert('catches', item.toMap());
  }

  Future<List<CatchLog>> getAllCatches() async {
    final db = await instance.database;
    final result = await db.query('catches', orderBy: 'id DESC');
    return result.map((json) => CatchLog.fromMap(json)).toList();
  }

  Future<int> deleteCatch(int id) async {
    final db = await instance.database;
    return await db.delete('catches', where: 'id = ?', whereArgs: [id]);
  }
}
