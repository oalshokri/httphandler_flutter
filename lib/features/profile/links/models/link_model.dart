class LinkResponse {
  int? totalResults;
  List<Link> results = [];

  LinkResponse.fromJson(Map<String, dynamic> json) {
    //you can use your custom json field depend on api response
    // totalResults = json['total_results'];
    if (json['links'] != null) {
      json['links'].forEach((v) {
        results.add(Link.fromJson(v));
      });
    }
  }
}

class Link {
  int? id;
  String? title;
  String? link;
  String? username;
  int? isActive;
  int? userId;
  String? createdAt;
  String? updatedAt;

  Link(
      {this.id,
      this.title,
      this.link,
      this.username,
      this.isActive,
      this.userId,
      this.createdAt,
      this.updatedAt});

  Link.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    link = json['link'];
    username = json['username'];
    isActive = json['isActive'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['link'] = this.link;
    data['username'] = this.username;
    data['isActive'] = this.isActive;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
