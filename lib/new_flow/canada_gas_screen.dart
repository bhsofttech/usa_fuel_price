import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class StateGasPrice {
  final String state;
  final String price;
  final String change;
  final String changeClass;
  final String trend;
  final String endpoint; // ← New field (e.g. "/usa/ok")

  StateGasPrice({
    required this.state,
    required this.price,
    required this.change,
    required this.changeClass,
    required this.trend,
    required this.endpoint,
  });
}

class CanadaGasScreen extends StatefulWidget {
  const CanadaGasScreen({super.key});

  @override
  State<CanadaGasScreen> createState() => _CanadaGasScreenState();
}

class _CanadaGasScreenState extends State<CanadaGasScreen> {
  Future<List<StateGasPrice>>? _futureGasPrices;

  @override
  void initState() {
    super.initState();
    _futureGasPrices = _fetchGasPrices();
  }

  Future<List<StateGasPrice>> _fetchGasPrices() async {
    final url = Uri.parse('https://www.gasbuddy.com/can');

    final response = await http.get(
      url,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load Canada page: ${response.statusCode}');
    }

    final document = html_parser.parse(response.body);

    final container = document.querySelector('#searchItems');
    if (container == null) {
      throw Exception(
        'Could not find #searchItems container. The page may have changed or data is loaded via JavaScript.',
      );
    }

    final provinceRows = container.querySelectorAll('div.col-sm-12.col-xs-12');

    final List<StateGasPrice> list = [];

    for (final row in provinceRows) {
      final link = row.querySelector('a[href^="/can/"]');
      if (link == null) continue;

      final endpoint = link.attributes['href'] ?? ''; // e.g. "/can/on"

      // Extract province name
      final state = link.querySelector('.siteName')?.text.trim() ??
          link.text.split('\n').first.trim();

      final rowDiv = link.querySelector('div.row');
      if (rowDiv == null) continue;

      final cols = rowDiv.querySelectorAll('div');
      if (cols.length < 4) continue;

      final price =
          cols[1].text.trim(); // Note: Canada uses cents per litre (no $ sign)

      final changeSpan = cols[2].querySelector('span');
      final change = changeSpan?.text.trim() ?? '0.0';
      final changeClass = changeSpan?.classes.join(' ') ?? 'stable';

      // Determine trend from image src
      String trend = 'neutral';
      final img = cols[3].querySelector('img');
      if (img != null) {
        final src = img.attributes['src'] ?? '';
        if (src.contains('icon-trend-down'))
          trend = 'down';
        else if (src.contains('icon-trend-up')) trend = 'up';
      }

      if (price.isNotEmpty && state.isNotEmpty) {
        list.add(StateGasPrice(
          state: state,
          price: price,
          change: change,
          changeClass: changeClass,
          trend: trend,
          endpoint: endpoint,
        ));
      }
    }

    return list;
  }

// Helper to better extract state when structure is messy
  String _extractStateFromContext(dom.Element element) {
    final possibleStates = [
      'Oklahoma', 'Kansas', 'Nebraska', 'Iowa', 'South Dakota', 'Arkansas',
      'North Dakota', 'Minnesota', 'Missouri', 'Mississippi', 'Georgia',
      // ... you can add more common ones if needed
    ];

    final text = element.text;
    for (final st in possibleStates) {
      if (text.contains(st)) return st;
    }
    return 'Unknown';
  }

  Color _getChangeColor(String changeClass) {
    if (changeClass.contains('rising')) return Colors.red;
    if (changeClass.contains('falling')) return Colors.green;
    return Colors.grey;
  }

  IconData _getTrendIcon(String trend) {
    if (trend == 'down') return Icons.arrow_downward;
    if (trend == 'up') return Icons.arrow_upward;
    return Icons.horizontal_rule; // neutral
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GasBuddy USA Prices (Scraped)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _futureGasPrices = _fetchGasPrices();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<StateGasPrice>>(
        future: _futureGasPrices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}\n\n'
                  'Tip: If data is missing, the site loads prices with JavaScript.\n'
                  'http.get may not capture it. Consider using flutter_webview_plugin or a backend scraper.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No data found. Site structure may have changed.'));
          }

          final prices = snapshot.data!;

          return ListView.builder(
            itemCount: prices.length,
            itemBuilder: (context, index) {
              final item = prices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Text(
                    item.state,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  title: Text(
                    '\$${item.price}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        item.change,
                        style: TextStyle(
                          color: _getChangeColor(item.changeClass),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getTrendIcon(item.trend),
                        color: item.trend == 'down'
                            ? Colors.blue
                            : (item.trend == 'up' ? Colors.green : Colors.grey),
                        size: 18,
                      ),
                    ],
                  ),
                  trailing: Text(
                    item.trend.toUpperCase(),
                    style: TextStyle(
                      color: item.trend == 'down' ? Colors.blue : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
