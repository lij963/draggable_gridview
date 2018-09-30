# draggable_gridview

实现一个简单的可拖拽Item的GridView。

## Getting Started
用起来大概是这样，有其他需求可以自行修改SortableGridView类
``` dart
SortableGridView(
        channelItems,
        childAspectRatio: 3.0, //宽高3比1
        crossAxisCount: 3, //3列
        scrollDirection: Axis.vertical, //竖向滑动
        canAccept: (oldIndex, newIndex) {
          return true;
        },
        itemBuilder: (context, data) {
          return Card(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Center(
              child: Text(data),
            ),
          ));
        },
      )
```

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).
