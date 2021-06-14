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
            height: 70,
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

class ChrisTucker extends StatelessWidget {
  ChrisTucker(
      {required this.controller,
      required this.height,
      required this.buckle,
      required this.children});

  final ScrollController controller;
  final double height;
  final Widget buckle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    double h = height;
    final spring = StatefulBuilder(builder: (context, setState) {
      controller.addListener(() {
        switch (controller.position.userScrollDirection) {
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
      });
      return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: h,
      );
    });
    return Stack(children: <Widget>[
      ConstrainedBox(
          constraints: BoxConstraints.tightFor(height: height), child: buckle),
      Column(
        children: [spring, ...children],
      )
    ]);
  }
}
