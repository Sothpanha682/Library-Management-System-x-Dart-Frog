import 'package:mysql_client/mysql_client.dart';
import 'db_config.dart';

/// Wrapped Row representing a SQL result row compatible with both map and index lookups
class DbRow {
  final Map<String, dynamic> fields;
  final List<dynamic> _indexedCols;

  DbRow(this.fields, this._indexedCols);

  dynamic operator [](dynamic key) {
    if (key is int) {
      return _indexedCols[key];
    }
    return fields[key];
  }
}

/// Wrapped Results representing an iterable of DbRows with metadata
class DbResults extends Iterable<DbRow> {
  final List<DbRow> _rows;
  final int? insertId;
  final int? affectedRows;

  DbResults({
    required List<DbRow> rows,
    this.insertId,
    this.affectedRows,
  }) : _rows = rows;

  @override
  Iterator<DbRow> get iterator => _rows.iterator;

  @override
  bool get isEmpty => _rows.isEmpty;

  @override
  bool get isNotEmpty => _rows.isNotEmpty;

  @override
  DbRow get first => _rows.first;

  @override
  int get length => _rows.length;
}

/// Database Manager wrapping MySQL connection and queries
class DbConnection {
  static MySQLConnection? _connection;

  static Future<MySQLConnection> getConnection() async {
    if (_connection != null && _connection!.connected) {
      return _connection!;
    }

    final conn = await MySQLConnection.createConnection(
      host: DbConfig.host == 'localhost' ? '127.0.0.1' : DbConfig.host,
      port: DbConfig.port,
      userName: DbConfig.user,
      password: DbConfig.password,
      databaseName: DbConfig.dbName,
      secure: true,
    );

    await conn.connect();
    _connection = conn;
    return _connection!;
  }

  static Future<DbResults> _execute(dynamic executor, String sql, [List<Object?>? values]) async {
    IResultSet res;
    if (values != null && values.isNotEmpty) {
      final stmt = await executor.prepare(sql);
      try {
        res = await stmt.execute(values);
      } finally {
        await stmt.deallocate();
      }
    } else {
      res = await executor.execute(sql);
    }

    final dbRows = res.rows.map((r) {
      final fields = r.typedAssoc();
      final indexed = List.generate(res.cols.length, (i) => r.typedColAt(i));
      return DbRow(fields, indexed);
    }).toList();

    return DbResults(
      rows: dbRows,
      insertId: res.lastInsertID.toInt(),
      affectedRows: res.affectedRows.toInt(),
    );
  }

  static Future<DbResults> query(String sql, [List<Object?>? values]) async {
    final conn = await getConnection();
    return _execute(conn, sql, values);
  }

  static Future<T> transaction<T>(Future<T> Function(TransactionContext ctx) action) async {
    final conn = await getConnection();
    return conn.transactional((tx) async {
      return action(TransactionContext(tx));
    });
  }

  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}

class TransactionContext {
  TransactionContext(this._tx);
  final MySQLConnection _tx;

  Future<DbResults> query(String sql, [List<Object?>? values]) {
    return DbConnection._execute(_tx, sql, values);
  }
}
