import 'package:flutter/material.dart';
import 'package:orgacare_reader_sdk/orgacare_reader_sdk.dart';
import 'package:xml/xml.dart';

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
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final OrgacareReaderSdk _orgacareDemoPlugin = OrgacareReaderSdk();
  List<String> _logsAndData = [];

  void _loadVSD() async {
    try {
      final result = await _orgacareDemoPlugin.loadVSD();
      List<String> dataStrings = result != null ? [result] : [];
      final filteredDataNodes = _parseAndFilterXmlData(dataStrings);
      setState(() {
        _logsAndData.addAll(filteredDataNodes
            .map((node) => '${node.keys.first}: ${node.values.first}'));
      });
    } catch (e) {
      setState(() {
        _logsAndData.add('Error: $e');
      });
    }
  }

  final List<String> _nodesToDisplay = [
    'geburtsdatum',
    'vorname',
    'nachname',
    'geschlecht',
    'titel',
    'postleitzahl',
    'ort',
    'wohnsitzlaendercode',
    'strasse',
    'hausnummer',
    'beginn',
    'kostentraegerkennung',
    'kostentraegerlaendercode',
    'name',
    'versichertenart',
    'versicherten_id'
  ];
  List<Map<String, String>> _parseAndFilterXmlData(List<String> dataStrings) {
    List<Map<String, String>> nodes = [];
    for (var data in dataStrings) {
      final document = XmlDocument.parse(data);
      final elements = document.findAllElements('*');
      for (var element in elements) {
        final nodeName = element.name.toString().toLowerCase();
        if (_nodesToDisplay.contains(nodeName)) {
          final nodeContent = element.innerText;
          final formattedContent = _formatNodeContent(nodeName, nodeContent);
          nodes.add({element.name.toString(): formattedContent});
        }
      }
    }
    return nodes;
  }

  String _formatNodeContent(String nodeName, String content) {
    if ((nodeName == 'geburtsdatum' || nodeName == 'beginn') &&
        content.length == 8) {
      final year = content.substring(0, 4);
      final month = content.substring(4, 6);
      final day = content.substring(6, 8);
      return '$day.$month.$year';
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            ElevatedButton(
              onPressed: _loadVSD,
              child: const Text('Load VSD'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _logsAndData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_logsAndData[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
