import 'package:flutter/material.dart';

typedef bool CanAccept(int oldIndex, int newIndex);

typedef Widget DataWidgetBuilder<T>(BuildContext context, T data);

class SortableGridView<T> extends StatefulWidget {
  final DataWidgetBuilder<T> itemBuilder;
  final CanAccept canAccept;
  final List<T> dataList;
  final int crossAxisCount;
  final Axis scrollDirection;
  final double childAspectRatio;

  SortableGridView(
    this.dataList, {
    Key key,
    this.scrollDirection = Axis.vertical,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1.0,
    @required this.itemBuilder,
    @required this.canAccept,
  })  : assert(itemBuilder != null),
        assert(canAccept != null),
        assert(dataList != null && dataList.length >= 0),
        super(key: key);
  @override
  State<StatefulWidget> createState() => _SortableGridViewState<T>();
}

class _SortableGridViewState<T> extends State<SortableGridView> {
  List<T> dataList; //数据源
  List<T> dataListBackup; //数据源备份，在拖动时 会直接在数据源上修改 来影响UI变化，当拖动取消等情况，需要通过备份还原
  bool showItemWhenCovered = false; //手指覆盖的地方，即item被拖动时 底部的那个widget是否可见；
  int willAcceptIndex = -1; //当拖动覆盖到某个item上的时候，记录这个item的坐标
  int draggingItemIndex = -1; //当前被拖动的item坐标
  @override
  void initState() {
    super.initState();
    dataList = widget.dataList;
    dataListBackup = dataList.sublist(0);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: widget.childAspectRatio, //item宽高比
      scrollDirection: widget.scrollDirection, //默认vertical
      crossAxisCount: widget.crossAxisCount, //列数
      children: _buildGridChildren(context),
    );
  }

  //生成widget列表
  List<Widget> _buildGridChildren(BuildContext context) {
    final List list = List<Widget>();
    for (int x = 0; x < dataList.length; x++) {
      list.add(_buildDraggable(context, x));
    }
    return list;
  }

  //绘制一个可拖拽的控件。
  Widget _buildDraggable(BuildContext context, int index) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return LongPressDraggable(
          data: index,
          child: DragTarget<int>(
            //松手时 如果onWillAccept返回true 那么久会调用，本案例不使用。
            onAccept: (int data) {},
            //绘制widget
            builder: (context, data, rejects) {
              return willAcceptIndex >= 0 && willAcceptIndex == index
                  ? null
                  : widget.itemBuilder(context, dataList[index]);
            },
            //手指拖着一个widget从另一个widget头上滑走时会调用
            onLeave: (int data) {
              //TODO 这里应该还可以优化，当用户滑出而又没有滑入某个item的时候 可以重新排列  让当前被拖走的item的空白被填满
              print('$data is Leaving item $index');
              willAcceptIndex = -1;
              setState(() {
                showItemWhenCovered = false;
                dataList = dataListBackup.sublist(0);
              });
            },
            //接下来松手 是否需要将数据给这个widget？  因为需要在拖动时改变UI，所以在这里直接修改数据源
            onWillAccept: (int fromIndex) {
              print('$index will accept item $fromIndex');
              final accept = fromIndex != index;
              if (accept) {
                willAcceptIndex = index;
                showItemWhenCovered = true;
                dataList = dataListBackup.sublist(0);
                final fromData = dataList[fromIndex];
                setState(() {
                  dataList.removeAt(fromIndex);
                  dataList.insert(index, fromData);
                });
              }
              return accept;
            },
          ),
          onDragStarted: () {
            //开始拖动，备份数据源
            draggingItemIndex = index;
            dataListBackup = dataList.sublist(0);
            print('item $index ---------------------------onDragStarted');
          },
          onDraggableCanceled: (Velocity velocity, Offset offset) {
            print(
                'item $index ---------------------------onDragStarted,velocity = $velocity,offset = $offset');
            //拖动取消，还原数据源

            setState(() {
              willAcceptIndex = -1;
              showItemWhenCovered = false;
              dataList = dataListBackup.sublist(0);
            });
          },
          onDragCompleted: () {
            //拖动完成，刷新状态，重置willAcceptIndex
            print("item $index ---------------------------onDragCompleted");
            setState(() {
              showItemWhenCovered = false;
              willAcceptIndex = -1;
            });
          },
          //用户拖动item时，那个给用户看起来被拖动的widget，（就是会跟着用户走的那个widget）
          feedback: SizedBox(
            width: constraint.maxWidth,
            height: constraint.maxHeight,
            child: widget.itemBuilder(context, dataList[index]),
          ),
          //这个是当item被拖动时，item原来位置用来占位的widget，（用户把item拖走后原来的地方该显示啥？就是这个）
          childWhenDragging: Container(
            child: SizedBox(
              child: showItemWhenCovered
                  ? widget.itemBuilder(context, dataList[index])
                  : null,
            ),
          ),
        );
      },
    );
  }
}
