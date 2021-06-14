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
          constraints: BoxConstraints.tightFor(height: 100),
          buckle: TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          child: Column(
            children: <Widget>[
              _Spring(controller: _scrollController),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _Spring extends StatefulWidget {
  const _Spring({Key? key, required this.controller}) : super(key: key);

  final ScrollController controller;

  @override
  _SpringState createState() => _SpringState();
}

class _SpringState extends State<_Spring> {
  var height = 100.0;

  void _handler() {
    switch (widget.controller.position.userScrollDirection) {
      case ScrollDirection.forward:
        setState(() {
          height = 100.0;
        });
        break;
      case ScrollDirection.reverse:
        setState(() {
          height = 0;
        });
        break;
      case ScrollDirection.idle:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handler);
  }

  @override
  void didUpdateWidget(covariant _Spring oldWidget) {
    oldWidget.controller.removeListener(() {});
    widget.controller.addListener(_handler);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: height,
    );
  }
}

class ChrisTucker extends StatefulWidget {
  ChrisTucker(
      {required this.controller,
      required this.constraints,
      required this.buckle,
      required this.child});

  final ScrollController controller;
  final BoxConstraints constraints;
  final Widget buckle;
  final Widget child;

  @override
  _ChrisTuckerState createState() => _ChrisTuckerState();
}

class _ChrisTuckerState extends State<ChrisTucker> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ConstrainedBox(constraints: widget.constraints, child: widget.buckle),
        _Spring(controller: widget.controller),
        widget.child
      ],
    );
  }
}
