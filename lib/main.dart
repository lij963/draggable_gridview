import 'package:draggable_gridview/view/draggable_gridview.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Draggable Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> channelItems = List<String>();
  @override
  void initState() {
    super.initState();
    //初始化数据
    for (int x = 0; x < 20; x++) {
      channelItems.add("x = $x");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Draggable Demo'),
      ),
      body: SortableGridView(
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
      ),
    );
  }
}
