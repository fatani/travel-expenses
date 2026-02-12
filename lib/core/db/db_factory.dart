import 'app_database.dart';
import 'db_factory_stub.dart'
    if (dart.library.io) 'db_factory_native.dart'
    if (dart.library.html) 'db_factory_web.dart';

AppDatabase createDatabase() => createAppDatabase();

