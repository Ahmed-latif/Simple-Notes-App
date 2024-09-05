import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime createdAtDate;
  @HiveField(3)
  final DateTime createdAtTime; // Add the isPinned property

  Note(
      {required this.title,
      required this.content,
      required this.createdAtDate,
      required this.createdAtTime});

//   // Method to create a new instance with updated properties
//   Note copyWith({
//     String? title,
//     String? content,
//     DateTime? createdAtDate,
//     bool? isPinned,
//   }) {
//     return Note(
//       title: title ?? this.title,
//       content: content ?? this.content,
//       createdAtDate: createdAtDate ?? this.createdAtDate,
//       createdAtTime: createdAtTime ?? this.createdAtTime
//     );
//   }
}
