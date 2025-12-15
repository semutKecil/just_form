import 'package:example/basic_example.dart';
import 'package:example/todo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Just Form Example'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(32),
            child: TabBar(
              tabs: [
                Tab(text: "Basic", height: 32),
                Tab(text: "Todo", height: 32),
                Tab(text: "Variation", height: 32),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              BasicExample(),
              Todo(),
              Center(child: Text("Settings Page")),
            ],
          ),
        ),
      ),
    );
  }
}
