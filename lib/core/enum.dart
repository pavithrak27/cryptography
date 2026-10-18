enum Status { loading, success, error }

enum SortBy { marketCap, price, volume, change }

extension SortByApi on SortBy {
  String get apiKey {
    switch (this) {
      case SortBy.marketCap:
        return 'market_cap';
      case SortBy.price:
        return 'current_price';
      case SortBy.volume:
        return 'total_volume';
      case SortBy.change:
        return 'price_change_percentage_24h';
    }
  }

  String get label {
    switch (this) {
      case SortBy.marketCap:
        return 'Market Cap';
      case SortBy.price:
        return 'Price';
      case SortBy.volume:
        return 'Volume';
      case SortBy.change:
        return '24h %';
    }
  }
}


