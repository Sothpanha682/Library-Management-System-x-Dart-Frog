import 'package:mysql1/mysql1.dart';
import 'db_config.dart';

/// Database Manager wrapping MySQL connection and queries
class DbConnection {
  static MySqlConnection? _connection;

  static Future<MySqlConnection> getConnection() async {
    if (_connection != null) {
      return _connection!;
    }

    final settings = ConnectionSettings(
      host: DbConfig.host,
      port: DbConfig.port,
      user: DbConfig.user,
      password: DbConfig.password,
      db: DbConfig.dbName,
    );

    _connection = await MySqlConnection.connect(settings);
    return _connection!;
  }

  static Future<Results> query(String sql, [List<Object?>? values]) async {
    final conn = await getConnection();
    return conn.query(sql, values);
  }

  static Future<T> transaction<T>(Future<T> Function(TransactionContext ctx) action) async {
    final conn = await getConnection();
    return conn.transaction((ctx) async {
      return action(TransactionContext(ctx));
    });
  }

  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}

class TransactionContext {
  TransactionContext(this._ctx);
  final dynamic _ctx;

  Future<Results> query(String sql, [List<Object?>? values]) {
    return _ctx.query(sql, values) as Future<Results>;
  }
}
