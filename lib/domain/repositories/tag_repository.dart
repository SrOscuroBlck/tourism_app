// lib/domain/repositories/tag_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/tag.dart';
import '../../core/errors/failures.dart';

abstract class TagRepository {
  Future<Either<Failure, List<Tag>>> getUserTags();
  Future<Either<Failure, Tag>> getTagById(int id);
  Future<Either<Failure, List<Tag>>> getTagsByPerson(int personId);
  Future<Either<Failure, Tag>> createTag({
    required int personId,
    required String comment,
    String? photoUrl,
    double? latitude,
    double? longitude,
  });
  Future<Either<Failure, Tag>> updateTag({
    required int id,
    String? comment,
    String? photoUrl,
    double? latitude,
    double? longitude,
  });
  Future<Either<Failure, void>> deleteTag(int id);
}
