class Blog {
  Blog(Map<String, dynamic> map)
      : activityId = map['id'],
        title = map['title'],
        content = map['content'],
        imagesInfo = map['images_info'],
        latitude = map['latitude'] ?? -1,
        longtitude = map['longitude'] ?? -1,
        authorId = map['author_id'].toString(),
        createTime = map['create_time'],
        visitCount = map['visit_count'];

  final int activityId;
  final String title;
  final String content;
  final List<dynamic> imagesInfo;
  final String authorId;
  final double latitude;
  final double longtitude;
  final String createTime;
  final int visitCount;
}

class Address {
  Address.fromMap(Map<String, dynamic> map)
      : addressId = map['id'] ?? -1,
        addressName = map['address_name'] ?? '',
        latitude = map['latitude'] ?? -1,
        longtitude = map['longitude'] ?? -1;

  Address(this.addressName, this.latitude, this.longtitude) : addressId = -1;

  final int addressId;
  final String addressName;
  final double latitude;
  final double longtitude;
}
