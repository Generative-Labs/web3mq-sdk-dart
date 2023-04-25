// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
      page: json['page'] as int?,
      size: json['size'] as int,
    );

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'page': instance.page,
      'size': instance.size,
    };

TimestampPagination _$TimestampPaginationFromJson(Map<String, dynamic> json) =>
    TimestampPagination(
      limit: json['limit'] as int,
      timestampBeforeOrEqual: json['timestampBeforeOrEqual'] as int,
    );

Map<String, dynamic> _$TimestampPaginationToJson(
        TimestampPagination instance) =>
    <String, dynamic>{
      'timestampBeforeOrEqual': instance.timestampBeforeOrEqual,
      'limit': instance.limit,
    };
