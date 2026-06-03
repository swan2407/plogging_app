class PloggingResultSummary {
  const PloggingResultSummary({
    required this.duration,
    required this.distance,
    required this.trashCertifications,
    required this.trashCertificationCount,
    required this.region,
    required this.summary,
  });

  final String duration;
  final String distance;
  final String trashCertifications;
  final int trashCertificationCount;
  final String region;
  final String summary;
}
