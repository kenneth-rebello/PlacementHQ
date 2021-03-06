class Drive {
  final String id;
  final String batch;
  final String companyName;
  final String companyId;
  final String companyImageUrl;
  final double minSecMarks;
  final double minHighSecMarks;
  final double minBEMarks;
  final double minDiplomaMarks;
  final double minCGPA;
  final int maxGapYears;
  final int maxKTs;
  final String externalLink;
  final String jobDesc;
  final String location;
  final double ctc;
  final String category;
  final String companyMessage;
  final String expectedDate;
  final String regDeadline;
  int placed = 0;
  int registered = 0;
  Map<String, dynamic> requirements;

  Drive({
    this.id,
    this.batch,
    this.companyName,
    this.companyId,
    this.companyMessage,
    this.companyImageUrl,
    this.minSecMarks,
    this.minHighSecMarks,
    this.minDiplomaMarks,
    this.minBEMarks,
    this.minCGPA,
    this.maxGapYears,
    this.maxKTs,
    this.externalLink,
    this.jobDesc,
    this.location,
    this.ctc,
    this.category,
    this.expectedDate,
    this.regDeadline,
    this.requirements,
    this.registered,
    this.placed,
  });
}
