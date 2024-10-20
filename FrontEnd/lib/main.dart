import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/Services/HelperFunctions.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

//start
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

//app states
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var selectedIndex = 0;

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void SetNavState(value) {
    selectedIndex = value;
    notifyListeners();
  }

  List<dynamic> _data = [];
  Timer? _timer;

  List<dynamic> get data => _data;

  MyAppState() {
    _fetchData(search: '', sortBy: '', Order: 'asc');

    _timer = Timer.periodic(Duration(minutes: 10),
        (Timer t) => _fetchData(search: '', sortBy: '', Order: 'asc'));
  }

  Future<void> _fetchData(
      {String search = '', String sortBy = '', String Order = 'asc'}) async {
    final apiUrl =
        'http://10.0.2.2:5194/api/crypto?sortField=$sortBy&sortOrder=$Order&searchQuery=$search';

    const updateurl = "http://10.0.2.2:5194/api/crypto/update-data";

    try {
      await http.get(Uri.parse(updateurl));

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        _data = jsonDecode(response.body);

        notifyListeners();
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling API: $e');
    }
  }

  void changeSort(String sortBy, String order) {
    _fetchData(sortBy: sortBy, Order: order);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

//Page chooser
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var selectedIndex = context.watch<MyAppState>().selectedIndex;
    var appState = context.watch<MyAppState>();

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Markets();
      case 1:
        page = News();
      case 2:
        page = Search();
      case 3:
        page = Portfolio();
      case 4:
        page = Community();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        ),
        bottomNavigationBar: SafeArea(
          child: NavigationBar(
            indicatorColor: Colors.white,
            backgroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 10,
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              appState.SetNavState(value);
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.currency_bitcoin,
                    color: selectedIndex == 0
                        ? const Color.fromARGB(255, 15, 11, 255)
                        : Colors.grey),
                label: 'Markets',
              ),
              NavigationDestination(
                icon: Icon(Icons.article_outlined,
                    color: selectedIndex == 1
                        ? const Color.fromARGB(255, 15, 11, 255)
                        : Colors.grey),
                label: 'News',
              ),
              NavigationDestination(
                icon: Icon(Icons.search,
                    color: selectedIndex == 2
                        ? const Color.fromARGB(255, 15, 11, 255)
                        : Colors.grey),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.pie_chart_outline_outlined,
                    color: selectedIndex == 3
                        ? const Color.fromARGB(255, 15, 11, 255)
                        : Colors.grey),
                label: 'Portfolio',
              ),
              NavigationDestination(
                icon: Icon(Icons.question_answer_outlined,
                    color: selectedIndex == 4
                        ? const Color.fromARGB(255, 15, 11, 255)
                        : Colors.grey),
                label: 'Community',
              ),
            ],
          ),
        ),
      );
    });
  }
}

//Widgets
class PageHeader extends StatelessWidget {
  final String title;

  const PageHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => {appState.SetNavState(2)},
                      icon: Icon(Icons.search),
                    ),
                    IconButton(
                      onPressed: () => {},
                      icon: Icon(Icons.account_circle_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      MarketCapCard(),
      VolumeCard(),
      DominanceCard(),
      FearGreedCard()
    ]);
  }
}

class FearGreedCard extends StatelessWidget {
  const FearGreedCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        width: 95,
        child: Card(
          color: Colors.white,
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0), // Round the top-left corner
              bottomLeft: Radius.circular(0), // Round the bottom-left corner
              topRight: Radius.circular(12), // Square the top-right corner
              bottomRight:
                  Radius.circular(12), // Square the bottom-right corner
            ),
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: [
              Text(
                'Fear & Greed',
                style: TextStyle(
                    fontSize: 12, color: Colors.black.withOpacity(0.5)),
              ),
              Text(
                '43',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              )
            ],
          )),
        ));
  }
}

class DominanceCard extends StatelessWidget {
  const DominanceCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        width: 95,
        child: Card(
          color: Colors.white,
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0), // Round the top-left corner
              bottomLeft: Radius.circular(0), // Round the bottom-left corner
              topRight: Radius.circular(0), // Square the top-right corner
              bottomRight: Radius.circular(0), // Square the bottom-right corner
            ),
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: [
              Text(
                'Dominance',
                style: TextStyle(
                    fontSize: 12, color: Colors.black.withOpacity(0.5)),
              ),
              Text(
                '56.87%',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.currency_bitcoin_sharp,
                      size: 15, color: Colors.black.withOpacity(0.5)),
                  Text(
                    'BTC',
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          )),
        ));
  }
}

class VolumeCard extends StatelessWidget {
  const VolumeCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        width: 95,
        child: Card(
          color: Colors.white,
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0), // Round the top-left corner
              bottomLeft: Radius.circular(0), // Round the bottom-left corner
              topRight: Radius.circular(0), // Square the top-right corner
              bottomRight: Radius.circular(0), // Square the bottom-right corner
            ),
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: [
              Text(
                'Volume',
                style: TextStyle(
                    fontSize: 12, color: Colors.black.withOpacity(0.5)),
              ),
              Text(
                '£55.34 B',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '+15.30%',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              )
            ],
          )),
        ));
  }
}

class MarketCapCard extends StatelessWidget {
  const MarketCapCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        width: 95,
        child: Card(
          color: Colors.white,
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), // Round the top-left corner
              bottomLeft: Radius.circular(12), // Round the bottom-left corner
              topRight: Radius.circular(0), // Square the top-right corner
              bottomRight: Radius.circular(0), // Square the bottom-right corner
            ),
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: [
              Text(
                'Market Cap',
                style: TextStyle(
                    fontSize: 12, color: Colors.black.withOpacity(0.5)),
              ),
              Text(
                '£1.69 T',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '+15.90%',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              )
            ],
          )),
        ));
  }
}

class PageNavVertiWidget extends StatefulWidget {
  final Map<String, WidgetBuilder> navItems;

  const PageNavVertiWidget({required this.navItems});

  @override
  State<PageNavVertiWidget> createState() => _PageNavVertiWidgetState();
}

class _PageNavVertiWidgetState extends State<PageNavVertiWidget> {
  late String _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.navItems.keys.first;
  }

  void _onNavItemTap(String item) {
    setState(() {
      _selectedItem = item;
    });
  }

  Widget _getSelectedPageContent() {
    return widget.navItems[_selectedItem]?.call(context) ?? Placeholder();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: widget.navItems.keys.map((item) {
                bool isSelected = item == _selectedItem;
                return TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Colors.transparent,
                  ),
                  onPressed: () => _onNavItemTap(item),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Dynamic content area below the navigation bar
          SizedBox(height: 594, child: _getSelectedPageContent())
        ],
      ),
    );
  }
}

class CoinsCardWidget extends StatefulWidget {
  const CoinsCardWidget({
    super.key,
  });

  @override
  State<CoinsCardWidget> createState() => _CoinsCardWidgetState();
}

class _CoinsCardWidgetState extends State<CoinsCardWidget> {
  final TextStyle commonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Colors.black,
  );

  void _onSort(String field) {
    setState(() {
      if (_currentSortField == field) {
        _isAscending = !_isAscending;
      } else {
        _currentSortField = field;
        _isAscending = true;
      }

      String order = _isAscending ? 'asc' : 'desc';
      context.read<MyAppState>().changeSort(field, order);
    });
  }

  String _currentSortField =
      ''; // Tracks the field by which data is being sorted
  bool _isAscending = true;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.data.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 19.0),
            child: Row(
              children: [
                SizedBox(width: 27, child: _buildSortableColumnHeader('#', '')),
                SizedBox(
                    width: 229,
                    child:
                        _buildSortableColumnHeader('Market Cap', 'marketcap')),
                SizedBox(
                    width: 85,
                    child: Container(
                        child: _buildSortableColumnHeader('Price', 'price'))),
                SizedBox(
                    width: 50,
                    child: _buildSortableColumnHeader('24h %', '24h')),
              ],
            ),
          ),
          Column(
            children: appState.data.map<Widget>((data) {
              return CoinsPageMainWidgetCards(
                index: data['cmcRank'] ?? 'N/A',
                ticker: data['symbol'] ?? 'Unknown',
                icon: data['logo'],
                marketcap: data['marketCap'] ?? 'N/A',
                price: data['price'] ?? 'N/A',
                graph: data['percentChange24h'] ?? 'N/A',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableColumnHeader(String title, String field) {
    return GestureDetector(
      onTap: () => _onSort(field),
      child: Row(
        children: [
          Text(
            title,
            style: commonTextStyle,
          ),
          if (_currentSortField == field) ...[
            Icon(
              _isAscending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
              size: 14,
              color: Colors.black,
            ),
          ],
        ],
      ),
    );
  }
}

class CoinsPageMainWidgetCards extends StatelessWidget {
  final int index;
  final String ticker;
  final String icon;
  final double marketcap;
  final double price;
  final double graph;

  const CoinsPageMainWidgetCards({
    super.key,
    required this.index,
    required this.ticker,
    required this.icon,
    required this.marketcap,
    required this.price,
    required this.graph,
  });

  double truncateToDecimalPlaces(num value, int fractionalDigits) =>
      (value * pow(10, fractionalDigits)).truncate() /
      pow(10, fractionalDigits);

  String formatPrice(num price) {
    int decimalPlaces;

    if (price >= 1) {
      decimalPlaces = 2;
    } else if (price >= 0.01) {
      decimalPlaces = 4;
    } else {
      decimalPlaces = 8;
    }

    final truncatedPrice = truncateToDecimalPlaces(price, decimalPlaces);

    final formattedPrice = NumberFormat("#,##0.${'0' * decimalPlaces}", "en_US")
        .format(truncatedPrice);

    return formattedPrice;
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = formatPrice(price);
    final formattedGraph = NumberFormat("#,##0.00").format(graph.abs());
    final formattedMarketCap = HelperFunctions.formatLargeNumber(marketcap);

    return SizedBox(
      height: 45,
      width: 400,
      child: Card(
        color: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.only(left: 3, right: 8),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: SizedBox(
                width: 30,
                child: Text(
                  '$index',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: 110,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Image.network(
                      icon,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticker,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                      Text('\$$formattedMarketCap',
                          style: TextStyle(color: Colors.black, fontSize: 10))
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                '\$$formattedPrice',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: SizedBox(
                width: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      graph < 0 ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                      color: graph < 0 ? Colors.red : Colors.green,
                      size: 16,
                    ),
                    Text(
                      '\$$formattedGraph%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: graph < 0 ? Colors.red : Colors.green,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class SearchBarFrameworkWidget extends StatefulWidget {
  const SearchBarFrameworkWidget({
    super.key,
  });

  @override
  State<SearchBarFrameworkWidget> createState() =>
      _SearchBarFrameworkWidgetState();
}

class _SearchBarFrameworkWidgetState extends State<SearchBarFrameworkWidget> {
  List<dynamic> _searchResults = [];
  String _searchQuery = "";

  Future<void> _searchCoins(String query) async {
    final url = Uri.parse('http://10.0.2.2:5194/api/crypto?searchQuery=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _searchResults = data;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });

                  if (value.isNotEmpty) {
                    _searchCoins(value);
                  } else {
                    setState(() {
                      _searchResults = [];
                    });
                  }
                },
                decoration: InputDecoration(
                    hintText: 'Search coins or addresses..',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: Icon(Icons.search),
                    iconColor: Colors.grey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 12)),
              ),
            ),
          ),
        ),
        _searchQuery.isEmpty
            ? Center(child: Text(''))
            : _searchResults.isNotEmpty
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 15),
                        child: SizedBox(
                          width: 500,
                          child: Text("Cryptoassets",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      SizedBox(
                        width: 600,
                        height: 681,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            return SearchCardsWidget(item: item);
                          },
                        ),
                      ),
                    ],
                  )
                : Center(child: Text('No results found')),
      ],
    );
  }
}

class SearchCardsWidget extends StatelessWidget {
  const SearchCardsWidget({
    super.key,
    required this.item,
  });

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: SizedBox(
        height: 50,
        width: 100,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black26,
                  width: 0.4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Image.network(
                    item['logo'] ?? '',
                    width: 20,
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(item['symbol'] ?? 'No symbol'),
                  ),
                  Text(item['name'] ?? 'No name',
                      style: TextStyle(color: Colors.black54)),
                  Spacer(),
                  Text('#${item['cmcRank']}',
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//pages
class Markets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PageHeader(title: "Markets"),
            OverviewWidget(),
            PageNavVertiWidget(
              navItems: {
                'Coins': (context) => CoinsPage(),
                'Watchlists': (context) => Watchlists(),
                'Overview': (context) => Placeholder(color: Colors.orange),
                'Earn': (context) => Placeholder(color: Colors.red),
                'Exchange': (context) => Placeholder(color: Colors.purple),
                'NFT': (context) => Placeholder(color: Colors.pink),
                'Chains': (context) => Placeholder(color: Colors.yellow),
                'Categories': (context) => Placeholder(color: Colors.brown),
              },
            )
          ],
        ));
  }
}

class News extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              PageHeader(title: "News"),
              PageNavVertiWidget(
                navItems: {
                  'Recommended': (context) => Placeholder(color: Colors.green),
                  'News': (context) => Placeholder(color: Colors.green),
                  'Videos': (context) => Placeholder(color: Colors.orange),
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class Search extends StatelessWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [SearchBarFrameworkWidget()],
      ),
    );
  }
}

class Community extends StatelessWidget {
  const Community({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          PageHeader(title: "Community"),
          PageNavVertiWidget(navItems: {
            'For You': (context) => Placeholder(),
            'Following': (context) => Placeholder(),
            'Topics': (context) => Placeholder(color: Colors.orange),
            'Lives': (context) => Placeholder(color: Colors.red),
            'Articles': (context) => Placeholder(color: Colors.purple),
          })
        ],
      ),
    );
  }
}

class CoinsPage extends StatelessWidget {
  const CoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CoinsCardWidget();
  }
}

class Watchlists extends StatelessWidget {
  const Watchlists({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Watchlist",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Icon(Icons.arrow_drop_down_sharp),
              Spacer(),
              Icon(
                Icons.add,
                color: Colors.black54,
              ),
              Icon(
                Icons.more_horiz,
                color: Colors.black54,
              ),
            ],
          ),
          SizedBox(height: 50),
          Image.asset('assets/watchliststarts.png',
              width: 200, height: 200, fit: BoxFit.cover),
          Text(
            "Your watchlist is empty",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          SizedBox(
            width: 280,
            child: Text(
              "Start building your watchlist by clicking button below.",
              style: TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue[800]),
                minimumSize: WidgetStateProperty.all(Size(500, 40)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // Makes the button corners square
                  ),
                ),
              ),
              child: Text(
                'Add Coins',
                style: TextStyle(color: Colors.white),
              )),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

class Portfolio extends StatelessWidget {
  const Portfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PageHeader(title: "Portfolio"),
          SizedBox(height: 50),
          Image.asset('assets/portfolioimage.png',
              width: 200, height: 200, fit: BoxFit.cover),
          SizedBox(
            width: 270,
            child: Text(
              "This portfolio needs some final touches...",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5),
          SizedBox(
            width: 280,
            child: Text(
              "Add a coin to get started.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.blue[800]),
                      minimumSize: WidgetStateProperty.all(Size(500, 40)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Makes the button corners square
                        ),
                      ),
                    ),
                    child: Text(
                      'Add transaction',
                      style: TextStyle(color: Colors.white),
                    )),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
