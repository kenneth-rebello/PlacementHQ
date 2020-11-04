class Offer {
  String id;
  String userId;
  String candidate;
  String department;
  String rollNo;
  String driveId;
  String companyName;
  String companyId;
  String companyImageUrl;
  double ctc;
  String category;
  String selectedOn;
  bool accepted;

  Offer({
    this.id,
    this.userId,
    this.candidate,
    this.rollNo,
    this.driveId,
    this.companyId,
    this.companyName,
    this.companyImageUrl,
    this.ctc,
    this.category,
    this.department,
    this.selectedOn,
    this.accepted,
  });

  String get acceptedValue {
    final res = this.accepted == null
        ? "K"
        : this.accepted == true
            ? "A"
            : "R";
    return res;
  }
}

class Data {
  String year;
  List<Offer> offers;

  Data({
    this.offers,
    this.year,
  });
}
