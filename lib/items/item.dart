import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/bin/drawer.dart';
import 'package:iko_reliability_flutter/bin/end_drawer.dart';
import 'package:iko_reliability_flutter/items/item_notifier.dart';
import 'package:iko_reliability_flutter/main.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const Drawer(
          child: NavDrawer(),
        ),
        appBar: AppBar(
          title: const Text("Item Search & Request"),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ],
        ),
        endDrawer: const EndDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: const [
              ItemSearchWidget(),
              Expanded(child: ItemResultDisplay()),
            ],
          ),
        ));
  }
}

class ItemResultDisplay extends StatefulWidget {
  const ItemResultDisplay({super.key});

  @override
  State<ItemResultDisplay> createState() => _ItemResultDisplayState();
}

class _ItemResultDisplayState extends State<ItemResultDisplay> {
  final ScrollController _controller = ScrollController();
  List<String> items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  ItemNotifier? _itemNotifier;
  VoidCallback? _notifierListener;

  @override
  void initState() {
    super.initState();
    // Add listener to ItemNotifier after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itemNotifier = context.read<ItemNotifier>();
      _notifierListener = () {
        setState(() {
          items.clear();
          _hasMore = true;
        });
        _loadMore();
      };
      _itemNotifier?.addListener(_notifierListener!);
    });
    _loadMore();
    _controller.addListener(() {
      if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 200 &&
          !_isLoading) {
        if (!_hasMore) {
          _loadMore();
        }
      }
    });
  }

  void _loadMore() async {
    setState(() => _isLoading = true);
    var nextItems = context.read<ItemNotifier>().getResults();
    setState(() {
      items.addAll(nextItems);
      _isLoading = false;
      if (nextItems.isEmpty) {
        _hasMore = false;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_itemNotifier != null && _notifierListener != null) {
      _itemNotifier!.removeListener(_notifierListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _isLoading
              ? Center(
                  child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ))
              : SizedBox.shrink();
        }
        // Example: build different widgets based on index
        if (index % 2 == 0) {
          return ListTile(title: Text('Item ${items[index]}'));
        } else {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Card ${items[index]}'),
            ),
          );
        }
      },
    );
  }
}

class ItemSearchWidget extends StatefulWidget {
  const ItemSearchWidget({super.key});

  @override
  State<ItemSearchWidget> createState() => _ItemSearchWidgetState();
}

class _ItemSearchWidgetState extends State<ItemSearchWidget> {
  TextEditingController searchTextFieldController = TextEditingController();

  @override
  void dispose() {
    searchTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchTextFieldController,
            decoration: InputDecoration(
              labelText: 'Search Description',
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            showCursor: true,
          ),
        ),
        IconButton(
          onPressed: () async {
            final itemNotifier = context.read<ItemNotifier>();
            itemNotifier.newResults(await itemDatabase!
                .rankResults(phrases: [searchTextFieldController.text]));
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.travel_explore),
        ),
      ],
    );
  }
}
