import 'package:flutter/material.dart';
import 'package:flutter_simple_multiselect/flutter_simple_multiselect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Simple Multiselect Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Simple Multiselect Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Color lineColor = const Color.fromRGBO(36, 37, 51, 0.04);
  List selectedItems = [];
  List selectedItemsAsync = [];
  Map? singleItem;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> testData = [
    {"uuid": 1, "name": "Alfred Johanson"},
    {"uuid": 2, "name": "Goran Borovic"},
    {"uuid": 3, "name": "Ivan Horvat"},
    {"uuid": 4, "name": "Bjorn Sigurdson"}
  ];

  Future<List<Map<String, dynamic>>> searchFunction(query) async {
    return testData.where((element) {
      return element["name"].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<Map<String, dynamic>>> searchFunctionAsync(query) async {
    return Future.delayed(const Duration(seconds: 1), () {
      return testData.where((element) {
        return element["name"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            title: Text(widget.title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                autovalidateMode: AutovalidateMode.disabled,
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text("Static data multiselect")),
                    _staticData(),
                    const Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 20),
                        child: Text("Async data multiselect")),
                    _asyncData(),
                    const Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 20),
                        child: Text("Data single select")),
                    _staticSingleData(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: ElevatedButton(
                          child: const Text("submit"),
                          onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {}
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _staticSingleData() {
    return FlutterMultiselect(
        multiselect: false,
        autofocus: false,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        enableBorderColor: lineColor,
        focusedBorderColor: lineColor,
        borderRadius: 5,
        borderSize: 2,
        validator: (value) {
          if (value == null || value == "") {
            return "Required";
          }
          return null;
        },
        resetTextOnSubmitted: true,
        minTextFieldWidth: 300,
        suggestionsBoxMaxHeight: 300,
        length: 1,
        tagBuilder: (context, index) => SelectTag(
              index: index,
              label: selectedItems[index]["name"],
              onDeleted: (value) {
                selectedItems.removeAt(index);
                setState(() {});
              },
            ),
        suggestionBuilder: (context, state, data) {
          var existing = singleItem == data;
          return Material(
            child: GestureDetector(
              onPanDown: (_) {
                singleItem = existing ? null : data;

                setState(() {
                  state.selectAndClose(data,
                      singleItem != null ? singleItem!["name"].toString() : "");
                });
              },
              child: ListTile(
                enabled: true,
                selected: existing,
                trailing: existing ? const Icon(Icons.check) : null,
                selectedColor: Colors.white,
                selectedTileColor: Colors.green,
                dense: true,
                title: Text(data["name"].toString()),
              ),
            ),
          );
        },
        suggestionsBoxElevation: 0,
        suggestionsBoxRadius: 12,
        findSuggestions: (String query) async {
          setState(() {
            isLoading = true;
          });
          var data = await searchFunction(query);
          setState(() {
            isLoading = false;
          });
          return data;
        });
  }

  Widget _staticData() {
    return FlutterMultiselect(
        autofocus: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        enableBorderColor: lineColor,
        focusedBorderColor: lineColor,
        borderRadius: 5,
        borderSize: 2,
        resetTextOnSubmitted: true,
        minTextFieldWidth: 300,
        suggestionsBoxMaxHeight: 300,
        length: selectedItems.length,
        tagBuilder: (context, index) => SelectTag(
              index: index,
              label: selectedItems[index]["name"],
              onDeleted: (value) {
                selectedItems.removeAt(index);
                setState(() {});
              },
            ),
        suggestionBuilder: (context, state, data) {
          var existingIndex = selectedItems
              .indexWhere((element) => element["uuid"] == data["uuid"]);
          var selectedData = data;
          return Material(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanDown: (_) {
                if (existingIndex >= 0) {
                  selectedItems.removeAt(existingIndex);
                } else {
                  selectedItems.add(data);
                }

                state.selectAndClose(data);
                setState(() {});
              },
              child: ListTile(
                dense: true,
                selected: existingIndex >= 0,
                trailing: existingIndex >= 0 ? const Icon(Icons.check) : null,
                selectedColor: Colors.white,
                selectedTileColor: Colors.green,
                title: Text(selectedData["name"].toString()),
              ),
            ),
          );
        },
        // suggestionsBoxElevation: 10,
        suggestionsBoxRadius: 12,
        findSuggestions: (String query) async {
          setState(() {
            isLoading = true;
          });
          var data = await searchFunction(query);
          setState(() {
            isLoading = false;
          });
          return data;
        });
  }

  Widget _asyncData() {
    return FlutterMultiselect(
        autofocus: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        enableBorderColor: lineColor,
        focusedBorderColor: lineColor,
        borderRadius: 5,
        borderSize: 2,
        suggestionsBoxRadius: 12,
        resetTextOnSubmitted: true,
        minTextFieldWidth: 300,
        validator: (value) {
          if (selectedItemsAsync.length < 2) {
            return "Min 2 items required";
          }
          return null;
        },
        suggestionsBoxMaxHeight: 300,
        length: selectedItemsAsync.length,
        isLoading: isLoading,
        tagBuilder: (context, index) => SelectTag(
              index: index,
              label: selectedItemsAsync[index]["name"],
              onDeleted: (value) {
                selectedItemsAsync.removeAt(index);
                setState(() {});
              },
            ),
        suggestionBuilder: (context, state, data) {
          var existingIndex = selectedItemsAsync
              .indexWhere((element) => element["uuid"] == data["uuid"]);
          var selectedData = data;
          return Material(
              child: GestureDetector(
            onPanDown: (_) {
              var existingIndex = selectedItemsAsync
                  .indexWhere((element) => element["uuid"] == data["uuid"]);
              if (existingIndex >= 0) {
                selectedItemsAsync.removeAt(existingIndex);
              } else {
                selectedItemsAsync.add(data);
              }

              state.selectAndClose(data);
              setState(() {});
            },
            child: ListTile(
              selected: existingIndex >= 0,
              trailing: existingIndex >= 0 ? const Icon(Icons.check) : null,
              selectedColor: Colors.white,
              selectedTileColor: Colors.green,
              title: Text(selectedData["name"].toString()),
            ),
          ));
        },
        suggestionsBoxElevation: 0,
        findSuggestions: (String query) async {
          setState(() {
            isLoading = true;
          });
          var data = await searchFunctionAsync(query);
          setState(() {
            isLoading = false;
          });
          return data;
        });
  }
}

class SelectTag extends StatelessWidget {
  const SelectTag({
    super.key,
    required this.label,
    required this.onDeleted,
    required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;
  final Color darkAlias6 = const Color.fromRGBO(36, 37, 51, 0.06);

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: darkAlias6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelPadding: const EdgeInsets.only(left: 8.0),
      label: Text(label),
      deleteIcon: const Icon(
        Icons.close,
        size: 18,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}
