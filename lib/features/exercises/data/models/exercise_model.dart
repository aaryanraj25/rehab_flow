class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.targetMuscle,
    required this.description,
    required this.instructions,
    required this.equipment,
    this.thumbnailUrl,
    this.imageUrl,
    this.relatedIds = const [],
  });

  final String id;
  final String name;
  final String category;
  final String difficulty;
  final String targetMuscle;
  final String description;
  final String instructions;
  final String equipment;
  final String? thumbnailUrl;
  final String? imageUrl;
  final List<String> relatedIds;

  /// Splits instructions into readable step list for the detail UI.
  List<String> get instructionSteps {
    final trimmed = instructions.trim();
    if (trimmed.isEmpty) return const [];

    final parts = trimmed
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return parts.isEmpty ? [trimmed] : parts;
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      targetMuscle: json['targetMuscle'] as String? ?? 'Full Body',
      description: json['description'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      equipment: json['equipment'] as String? ?? 'None',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      relatedIds: (json['relatedIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'difficulty': difficulty,
        'targetMuscle': targetMuscle,
        'description': description,
        'instructions': instructions,
        'equipment': equipment,
        'thumbnailUrl': thumbnailUrl,
        'imageUrl': imageUrl,
        'relatedIds': relatedIds,
      };
}

/// Result wrapper so UI can show cache / offline / soft-refresh failure state.
class ExerciseFetchResult {
  const ExerciseFetchResult({
    required this.exercises,
    required this.fromCache,
    this.isOffline = false,
    this.refreshFailed = false,
  });

  final List<ExerciseModel> exercises;
  final bool fromCache;
  final bool isOffline;

  /// True when a forced remote refresh failed but local cache/asset was used.
  final bool refreshFailed;
}
