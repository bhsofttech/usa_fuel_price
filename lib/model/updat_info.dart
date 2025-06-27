class UpdateInfo {
  String title;
  String image;
  String link;
  String date;

  UpdateInfo(
      {this.title = "", this.image = "", this.link = "", this.date = ""});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        title: json["title"] ?? "",
        image: json["image"] ?? "",
        link: json["link"] ?? "",
        date: json["date"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "image": image,
        "link": link,
      };
}
