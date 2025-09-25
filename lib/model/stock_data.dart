class StockData {
  final String price;
  final String changePercent;
  final String volume;
  final String relativeVolume;
  final String marketCap;
  final String peRatio;
  final String epsDilTTM;
  final String epsDilGrowthYoY;
  final String dividendYield;
  final String sector;
  final String image;
  final String shortName;
  final String symbol;
  final String url;

  StockData({
    this.price = "",
    this.changePercent = "",
    this.volume = "",
    this.relativeVolume = "",
    this.marketCap = "",
    this.peRatio = "",
    this.epsDilTTM = "",
    this.epsDilGrowthYoY = "",
    this.dividendYield = "",
    this.sector = "",
    this.image = "",
    this.shortName = "",
    this.symbol = "",
    this.url="",
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      image: json["image"] ?? '',
      url: json["irl"]??"",
      shortName: json["short_name"] ?? '',
      symbol: json['symbol'] ?? '',
      price: json['price'] ?? '',
      changePercent: json['change_percent'] ?? '',
      volume: json['volume'] ?? '',
      relativeVolume: json['relative_volume'] ?? '',
      marketCap: json['market_cap'] ?? '',
      peRatio: json['pe_ratio'] ?? '',
      epsDilTTM: json['eps_dil_ttm'] ?? '',
      epsDilGrowthYoY: json['eps_dil_growth_yoy'] ?? '',
      dividendYield: json['dividend_yield'] ?? '',
      sector: json['sector'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "image": image,
      "url" : url,
      "short_name": shortName,
      'symbol': symbol,
      'price': price,
      'change_percent': changePercent,
      'volume': volume,
      'relative_volume': relativeVolume,
      'market_cap': marketCap,
      'pe_ratio': peRatio,
      'eps_dil_ttm': epsDilTTM,
      'eps_dil_growth_yoy': epsDilGrowthYoY,
      'dividend_yield': dividendYield,
      'sector': sector,
    };
  }

  String getValueByIndex(int index) {
    switch (index) {
      case 0:
        return symbol;
      case 1:
        return price;
      case 2:
        return changePercent;
      case 3:
        return volume;
      case 4:
        return relativeVolume;
      case 5:
        return marketCap;
      case 6:
        return peRatio;
      case 7:
        return epsDilTTM;
      case 8:
        return epsDilGrowthYoY;
      case 9:
        return dividendYield;
      case 10:
        return sector;
      default:
        return '';
    }
  }

}
