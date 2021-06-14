import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

const _colorsPool = <Color>[
  Colors.red,
  Colors.yellowAccent,
  Colors.blueAccent,
  Colors.purpleAccent,
  Colors.brown,
  Colors.amber,
  Colors.pink,
  Colors.greenAccent
];

Color _getRandomColor() {
  final rand = math.Random();
  final n = rand.nextInt(5);
  return _colorsPool[n];
}

class MyHomePage extends StatelessWidget {
  final _refresherController = RefreshController(initialRefresh: true);
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ChrisTucker(
            controller: _scrollController,
            buckle: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            children: <Widget>[
              Container(
                height: 80,
                color: Colors.black,
                child: Center(
                  child: const Text(
                    'Header',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: SmartRefresher(
                  controller: _refresherController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: () async {
                    _refresherController.refreshCompleted();
                  },
                  onLoading: () async {},
                  header: const MaterialClassicHeader(),
                  child: GridView.builder(
                    controller: _scrollController,
                    itemCount: 40,
                    itemBuilder: (context, i) => Container(
                      color: _getRandomColor(),
                      height: 150.0,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 2.12,
                    ),
                  ),
                ),
              )
            ]),
      ),
    );
  }
}

class ChrisTucker extends StatefulWidget {
  static const duration = Duration(milliseconds: 200);

  ChrisTucker(
      {required this.controller, required this.buckle, required this.children});

  final ScrollController controller;
  final Widget buckle;
  final List<Widget> children;

  @override
  _ChrisTuckerState createState() => _ChrisTuckerState();
}

class _ChrisTuckerState extends State<ChrisTucker> {
  final GlobalKey globalKey = GlobalKey();
  double? height;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final globalKeyContext = globalKey.currentContext;
      if (globalKeyContext != null) {
        setState(() {
          height =
              (globalKeyContext.findRenderObject() as RenderBox).size.height;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var h = height;
    ScrollDirection? direction;
    final spring = StatefulBuilder(builder: (context, setState) {
      widget.controller.addListener(() {
        final d = widget.controller.position.userScrollDirection;
        if (d != direction) {
          direction = d;
          switch (d) {
            case ScrollDirection.forward:
              setState(() {
                h = height;
              });
              break;
            case ScrollDirection.reverse:
              setState(() {
                h = 0.0;
              });
              break;
            case ScrollDirection.idle:
              break;
          }
        }
      });
      return AnimatedContainer(
        duration: ChrisTucker.duration,
        height: h ?? 0.0,
      );
    });
    return Stack(children: <Widget>[
      Container(key: globalKey, child: widget.buckle),
      Column(
        children: [spring, ...widget.children],
      )
    ]);
  }
}
