class Blog {
  Blog(Map<String, dynamic> map)
      : activityId = map['id'],
        title = map['title'],
        content = map['content'],
        imagesInfo = map['images_info'],
        latitude = map['latitude'] ?? -1,
        longtitude = map['longitude'] ?? -1,
        authorId = map['author_id'].toString(),
        createTime = map['create_time'];

  bool isSaved = false;
  final int activityId;
  final String title;
  final String content;
  final List<dynamic> imagesInfo;
  final String authorId;
  final double latitude;
  final double longtitude;
  final String createTime;
}
