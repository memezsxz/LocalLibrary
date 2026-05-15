// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentPage _$CommentPageFromJson(Map<String, dynamic> json) => CommentPage(
  items: (json['items'] as List<dynamic>)
      .map((e) => Comment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CommentPageToJson(CommentPage instance) =>
    <String, dynamic>{'items': instance.items};
