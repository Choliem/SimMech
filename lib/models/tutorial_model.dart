class TutorialModel {
  final String id;
  final String title;
  final String vehicleTag;
  final String difficulty;
  final String videoUrl;
  final String description;
  final List<String> steps; // Daftar langkah teks
  final List<String> toolIds; // ID Produk yang dipakai (untuk link ke Shop)

  TutorialModel({
    required this.id,
    required this.title,
    required this.vehicleTag,
    required this.difficulty,
    required this.videoUrl,
    this.description = '',
    this.steps = const [],
    this.toolIds = const [],
  });

  factory TutorialModel.fromMap(Map<String, dynamic> data, String id) {
    return TutorialModel(
      id: id,
      title: data['title'] ?? 'Tanpa Judul',
      vehicleTag: data['vehicle_tag'] ?? 'General',
      difficulty: data['difficulty'] ?? 'Mudah',
      videoUrl: data['video_url'] ?? '',
      description: data['description'] ?? '',
      // Konversi List dynamic ke List String dengan aman
      steps: List<String>.from(data['steps'] ?? []),
      toolIds: List<String>.from(data['tool_ids'] ?? []),
    );
  }
}
