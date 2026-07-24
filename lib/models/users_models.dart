class UserModel {
  final int? id;
  final String email;
  final String password;
  final bool isAdmin;
  final bool canAdd;
  final int? farmId; // 👈 تم التعديل إلى int? بدلاً من String?
  String? createdAt = DateTime.now().toIso8601String();

  UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.isAdmin,
    required this.canAdd,
    this.farmId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      // "id": id,
      "email": email,
      "password": password,
      "is_admin": isAdmin ? 1 : 0,
      "can_add": canAdd ? 1 : 0,
      "farm_id": farmId,
      "created_at": createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      // id: map["id"],
      email: map["email"] ?? "",
      password: map["password"] ?? "",
      isAdmin: map["is_admin"] == 1,
      canAdd: map["can_add"] == 1,
      farmId:
          map["farm_id"] is int
              ? map["farm_id"]
              : int.tryParse(map["farm_id"]?.toString() ?? ''),
      createdAt: map["created_at"] ?? "",
    );
  }
}
