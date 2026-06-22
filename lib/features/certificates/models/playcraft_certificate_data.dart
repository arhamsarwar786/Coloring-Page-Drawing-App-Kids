class PlayCraftCertificateData {
  const PlayCraftCertificateData({
    required this.childName,
    required this.certificateId,
    required this.issuedAt,
    this.milestoneTitle = 'Creative Star Milestone',
    this.milestoneNumber = 1,
    this.achievementText =
        'For completing a PlayCraft Kids creative challenge with curiosity, focus, and colorful imagination.',
    this.teamSignatureName = 'PlayCraft Kids',
    this.parentSignatureName = 'Parent / Guardian',
  });

  final String childName;
  final String certificateId;
  final DateTime issuedAt;
  final String milestoneTitle;
  final int milestoneNumber;
  final String achievementText;
  final String teamSignatureName;
  final String parentSignatureName;
}
