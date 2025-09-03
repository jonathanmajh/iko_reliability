import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/bin/consts.dart';
import 'package:iko_reliability_flutter/bin/drawer.dart';
import 'package:iko_reliability_flutter/bin/end_drawer.dart';
import 'package:iko_reliability_flutter/items/item_db.dart';
import 'package:iko_reliability_flutter/items/item_notifier.dart';
import 'package:iko_reliability_flutter/main.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

/// Intent to perform search
class Search extends Intent {
  const Search();
}

/// Intent to extended search
class SearchExt extends Intent {
  const SearchExt();
}

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
  Map<String, ItemCache> itemDetails = {};
  Map<String, ItemCache> inventoryDetails = {};
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
    final details = await itemDatabase!.getItemDetails(items: nextItems);
    setState(() {
      items.addAll(nextItems);
      itemDetails.addAll(details);
      _isLoading = false;
      if (nextItems.isEmpty) {
        _hasMore = false;
        return;
      }
      if (nextItems.length < 50) {
        _loadMore();
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
        final formattedText = textFormatter(
          text: itemDetails[items[index]]!.description,
          searchTerms: context.watch<ItemNotifier>().searchTerms,
        );
        double percent = (((formattedText.length - 1) / 2) /
            context.watch<ItemNotifier>().searchTerms.length);
        if (percent > 1) {
          percent = 1;
        }
        final colour = percent > 0.7
            ? Colors.green
            : (percent > 0.4 ? Colors.orange : Colors.red);
        return Card(
            child: ListTile(
                // minTileHeight: 200,
                leading: CircularPercentIndicator(
                  percent: percent,
                  center: Text('${(percent * 100).toStringAsFixed(0)}%'),
                  progressColor: colour,
                  radius: 24,
                ),
                title: Text(items[index]),
                subtitle: Text.rich(
                  TextSpan(
                      children: itemDetails.containsKey(items[index])
                          ? formattedText
                          : null),
                ),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  // show issue unit
                  Text(itemDetails[items[index]]!.uom ?? ''),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy Item Number',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: items[index]));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Copied ${items[index]} to clipboard'),
                      ));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    tooltip: 'Open in Maximo',
                    onPressed: () {
                      // TODO openInIKO(items[index]);
                    },
                  ),
                ])));
      },
    );
  }
}

List<TextSpan> textFormatter(
    {required String text, required List<String> searchTerms}) {
  for (var term in searchTerms) {
    text = text.replaceAll(term, '**$term**');
  }
  final style = TextStyle(fontWeight: FontWeight.bold);
  final List<TextSpan> children = [];
  final List<String> split = text.split('**');
  for (int i = 0; i < split.length; i++) {
    if (i % 2 == 0) {
      children.add(TextSpan(text: split[i]));
    } else {
      children.add(TextSpan(
        text: split[i],
        style: (style),
      ));
    }
  }
  return children;
  // Text.rich(TextSpan(children: children));
}

Future<List<String>> cleanSearchText(String input) async {
  String cleaned = input.toUpperCase();
  for (var char in itemSearchDescCleanup) {
    cleaned = cleaned.replaceAll(char, ' ');
  }
  // Remove extra spaces
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

  // replace abbreviations and manufacturers
  final replacements = await itemDatabase!.getReplacements().get();
  for (var row in replacements) {
    cleaned = cleaned.replaceAll(row.origText, row.replaceText);
  }
  debugPrint('Cleaned Search Text: $cleaned');
  return cleaned.split(' ');
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
    return Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): Search(),
          SingleActivator(LogicalKeyboardKey.enter, shift: true): SearchExt(),
        },
        child: Actions(
            actions: <Type, Action<Intent>>{
              Search: CallbackAction<Search>(
                onInvoke: (Search intent) => {_performSearch()},
              ),
              SearchExt: CallbackAction<SearchExt>(
                onInvoke: (SearchExt intent) =>
                    {_performSearch(extended: true)},
              ),
            },
            child: Row(
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
                    _performSearch();
                  },
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: () {
                    _performSearch(extended: true);
                  },
                  icon: const Icon(Icons.travel_explore),
                ),
              ],
            )));
  }

  void _performSearch({bool extended = false}) async {
    if (searchTextFieldController.text.isEmpty) {
      return;
    }
    final itemNotifier = context.read<ItemNotifier>();
    final searchTerms = await cleanSearchText(
      searchTextFieldController.text,
    );
    itemNotifier.newResults(
      ranked: await itemDatabase!.rankResults(phrases: searchTerms),
      searchTerm: searchTerms,
    );
  }
}
