import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';

part 'external_species_repository.g.dart';

class ExternalSpecies {
  final String popularName;
  final String scientificName;

  ExternalSpecies({required this.popularName, required this.scientificName});
}

@riverpod
class ExternalSpeciesRepository extends _$ExternalSpeciesRepository {
  Database? _db;
  static const _lastUpdateKey = 'flora_brasil_last_update';
  static const _defaultDate = '2026-05-01'; // Data do arquivo original

  @override
  Future<void> build() async {
    ref.onDispose(() {
      _db?.close();
      _db = null;
    });

    if (_db != null) return;

    final dbFile = await _getDatabaseFile();
    
    // O arquivo de 12KB (12288 bytes) é um banco SQLite vazio.
    // O real deve ter cerca de 11MB.
    bool shouldCopy = !await dbFile.exists() || await dbFile.length() < 1000000; // Menos de 1MB
    
    if (shouldCopy) {
      await _copyFromAssets(dbFile);
    }

    try {
      _db = sqlite3.open(dbFile.path);
      
      final countResult = _db!.select('SELECT COUNT(*) as cnt FROM external_species');
      final int count = countResult.first['cnt'] as int;

      if (count == 0) {
        _db!.close();
        await _copyFromAssets(dbFile);
        _db = sqlite3.open(dbFile.path);
      }
    } catch (e) {
      // Failed to open or verify DB
    }
  }

  Future<void> _copyFromAssets(File dbFile) async {
    try {
      final data = await rootBundle.load('assets/data/flora_brasil.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await dbFile.writeAsBytes(bytes, flush: true);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUpdateKey, _defaultDate);
    } catch (e) {
      // Error copying DB
    }
  }

  Future<int> getSpeciesCount() async {
    await future;
    if (_db == null) return 0;
    try {
      final count = _db!.select('SELECT COUNT(*) as cnt FROM external_species');
      return count.first['cnt'] as int;
    } catch (e) {
      return 0;
    }
  }

  Future<String> getLastUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdateKey) ?? _defaultDate;
  }

  Future<File> _getDatabaseFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(join(docsDir.path, 'external_flora.db'));
  }

  Future<List<ExternalSpecies>> search(String query) async {
    await future;
    if (_db == null || query.isEmpty) return [];

    try {
      final results = _db!.select(
        'SELECT popular_name, scientific_name FROM external_species '
        'WHERE popular_name LIKE ? OR scientific_name LIKE ? '
        'LIMIT 20',
        ['%$query%', '%$query%'],
      );

      return results.map((row) {
        return ExternalSpecies(
          popularName: row['popular_name'] as String,
          scientificName: row['scientific_name'] as String,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> downloadAndUpdate() async {
    // 1. Download
    final url = 'https://ipt.jbrj.gov.br/jbrj/archive.do?r=lista_especies_flora_brasil';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Falha no download');

    // 2. Unzip and Process
    final archive = ZipDecoder().decodeBytes(response.bodyBytes);
    
    String? taxonContent;
    String? vernacularContent;

    for (final file in archive) {
      if (file.name == 'taxon.txt') {
        taxonContent = utf8.decode(file.content);
      }
      if (file.name == 'vernacularname.txt') {
        vernacularContent = utf8.decode(file.content);
      }
    }

    if (taxonContent == null || vernacularContent == null) {
      throw Exception('Arquivos não encontrados no ZIP');
    }

    // 3. Rebuild SQLite locally
    final tempDbFile = File(join((await getTemporaryDirectory()).path, 'temp_flora.db'));
    if (await tempDbFile.exists()) {
      await tempDbFile.delete();
    }
    
    final tempDb = sqlite3.open(tempDbFile.path);
    tempDb.execute('CREATE TABLE external_species (popular_name TEXT, scientific_name TEXT)');
    tempDb.execute('CREATE INDEX idx_popular_name ON external_species (popular_name)');

    final taxonMap = <String, String>{};
    final taxonLines = const CsvToListConverter(fieldDelimiter: '\t').convert(taxonContent);
    final taxonHeader = taxonLines.first;
    final idIdx = taxonHeader.indexOf('id');
    final sciIdx = taxonHeader.indexOf('scientificName');

    for (var i = 1; i < taxonLines.length; i++) {
      final line = taxonLines[i];
      if (line.length > sciIdx) {
        taxonMap[line[idIdx].toString()] = line[sciIdx].toString();
      }
    }

    final vernacularLines = const CsvToListConverter(fieldDelimiter: '\t').convert(vernacularContent);
    final vernHeader = vernacularLines.first;
    final vIdIdx = vernHeader.indexOf('id');
    final vNameIdx = vernHeader.indexOf('vernacularName');

    final stmt = tempDb.prepare('INSERT INTO external_species VALUES (?, ?)');
    for (var i = 1; i < vernacularLines.length; i++) {
      final line = vernacularLines[i];
      if (line.length > vNameIdx) {
        final tId = line[vIdIdx].toString();
        if (taxonMap.containsKey(tId)) {
          stmt.execute([line[vNameIdx].toString(), taxonMap[tId]!]);
        }
      }
    }
    stmt.close();
    tempDb.close();

    // 4. Swap files
    _db?.close();
    final dbFile = await _getDatabaseFile();
    await tempDbFile.copy(dbFile.path);
    _db = sqlite3.open(dbFile.path);

    // 5. Update date
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String().split('T')[0]);
  }
}
