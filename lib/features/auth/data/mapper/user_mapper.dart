import '../../domain/entity/user_entity.dart';
import '../model/user_model.dart';

class UserMapper {
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      nickname: model.nickname,
      phone: model.phone,
      about: model.about,
      profile: model.profile,
      online: model.online,
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      nickname: entity.nickname,
      phone: entity.phone,
      about: entity.about,
      profile: entity.profile,
      online: entity.online,
    );
  }
}
