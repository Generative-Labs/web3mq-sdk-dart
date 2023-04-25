import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination.g.dart';

/// Pagination options.
@JsonSerializable()
class Pagination extends Equatable {
  /// The page of requesting items. Should be >= 1.
  final int? page;

  /// The amount of items requested from the APIs.
  final int size;

  const Pagination({this.page, required this.size});

  /// Create a new instance from a json
  static Pagination fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  /// Serialize to json
  Map<String, dynamic> toJson() => _$PaginationToJson(this);

  @override
  List<Object?> get props => [page, size];
}

@JsonSerializable()
class TimestampPagination extends Pagination {
  /// Filter on timestamp smaller than or equal the given value, in milliseconds.
  final int timestampBeforeOrEqual;

  int get limit {
    return size;
  }

  TimestampPagination({
    required int limit,
    int? timestampBeforeOrEqual,
  })  : timestampBeforeOrEqual =
            timestampBeforeOrEqual ?? DateTime.now().millisecondsSinceEpoch,
        super(page: null, size: limit);

  static TimestampPagination fromJson(Map<String, dynamic> json) =>
      _$TimestampPaginationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TimestampPaginationToJson(this);

  @override
  List<Object?> get props => [page, size, timestampBeforeOrEqual];
}
