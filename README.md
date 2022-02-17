# silu

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

``` Dart
bottomNavigationBar: BottomAppBar(
    shape: const CircularNotchedRectangle(),
    notchMargin: 2,
    child: SizedBox(
        height: 55,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                Expanded(child: _buildBottomItem(0, Icons.home, "首页")),
                Expanded(child: _buildBottomItem(1, Icons.library_music, "发现")),
                Expanded(child: _buildBottomItem(-1, null, "")),
                Expanded(child: _buildBottomItem(2, Icons.email, "消息")),
                Expanded(child: _buildBottomItem(3, Icons.person, "我的")),
            ],
        ),
    ),
),

_buildBottomItem(int index, IconData? iconData, String title) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [Icon(iconData), Text(title)],
      ),
    );
}
```

``` Dart
loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
        return child;
    }
    return Center(
        child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
        ),
    );
},
```