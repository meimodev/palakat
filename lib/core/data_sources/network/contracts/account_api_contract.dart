

abstract class AccountApiContract{
  Future<Map<String, dynamic>> getAccount(String uid);
  Future<Map<String, dynamic>> signIn();
  Future<Map<String, dynamic>> signOut();
  Future<Map<String, dynamic>> signUp();

}