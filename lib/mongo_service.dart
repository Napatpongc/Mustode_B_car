import 'package:mongo_dart/mongo_dart.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class MongoService {
  static const String _connectionString = "mongodb+srv://kitsanaphong:<db_password>@cluster0.zsqy3.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"; // ใส่ URI
  static const String _dbName = "Mustode_B_Car";
  static const String _collectionName = "users_id";

  static Future<DbCollection> _getCollection() async {
    var db = await Db.create(_connectionString);
    await db.open();
    return db.collection(_collectionName);
  }

  static String encryptPassword(String password) {
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.encrypt(password, iv: iv).base64;
  }

  static Future<bool> loginUser(String username, String password) async {
    var collection = await _getCollection();
    var encryptedPassword = encryptPassword(password);
    
    var user = await collection.findOne({
      'username': username,
      'password': encryptedPassword,
    });

    return user != null;
  }

  static Future<void> registerUser(String username, String password) async {
    var collection = await _getCollection();
    var encryptedPassword = encryptPassword(password);

    await collection.insertOne({
      'username': username,
      'password': encryptedPassword,
    });
  }
}
