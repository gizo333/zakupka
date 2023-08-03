import 'package:flutter/material.dart';

class StockPage extends StatefulWidget {
  final List<String> companiesToBuyList;

  StockPage({required this.companiesToBuyList});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<String> notes = [];
  List<TextEditingController> textControllers = [];

  @override
  void initState() {
    super.initState();
    notes = List.filled(widget.companiesToBuyList.length, "");
    textControllers = List.generate(
      widget.companiesToBuyList.length,
      (index) => TextEditingController(text: notes[index]),
    );
  }

  @override
  void dispose() {
    // Уничтожаем контроллеры, чтобы избежать утечки памяти
    for (var controller in textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checklist')),
      body: ListView.builder(
        itemCount: widget.companiesToBuyList.length,
        itemBuilder: (context, index) {
          final company = widget.companiesToBuyList[index];
          final textController = textControllers[index];

          return ExpansionTile(
            initiallyExpanded: true,
            title: Text(company),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      notes[index] = value;
                    });
                  },
                  controller: textController,
                  minLines: 1,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter notes',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
