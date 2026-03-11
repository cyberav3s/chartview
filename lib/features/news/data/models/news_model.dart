import 'package:chartview/features/news/domain/entities/news_entity.dart';

class NewsModel extends News {
  const NewsModel({
    required super.id,
    required super.headline,
    required super.summary,
    required super.source,
    required super.url,
    super.imageUrl,
    super.relatedSymbol,
    required super.category,
    required super.publishedAt,
    super.sentiment,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      headline: json['headline'] ?? json['title'] ?? '',
      summary: json['summary'] ?? json['description'] ?? '',
      source: json['source'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image'] ?? json['image_url'],
      relatedSymbol: json['related'] ?? json['symbol'],
      category: json['category'] ?? 'general',
      publishedAt: json['datetime'] != null
          ? (json['datetime'] is int
              ? DateTime.fromMillisecondsSinceEpoch(
                  (json['datetime'] as int) * 1000)
              : DateTime.parse(json['datetime']))
          : DateTime.now(),
      sentiment: json['sentiment'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'headline': headline,
        'summary': summary,
        'source': source,
        'url': url,
        'image': imageUrl,
        'related': relatedSymbol,
        'category': category,
        'datetime': publishedAt.millisecondsSinceEpoch ~/ 1000,
        'sentiment': sentiment,
      };

  static List<NewsModel> get mockNews => [
        NewsModel(
          id: '1',
          headline: 'Apple Reports Record Q4 Earnings, Revenue Up 15% YoY',
          summary:
              'Apple Inc. surpassed analyst expectations with its Q4 earnings report, posting record revenue driven by strong iPhone sales and growing services segment.',
          source: 'Reuters',
          url: 'https://reuters.com',
          imageUrl: 'https://picsum.photos/seed/news1/400/200',
          relatedSymbol: 'AAPL',
          category: 'earnings',
          publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
          sentiment: 1,
        ),
        NewsModel(
          id: '2',
          headline: 'Bitcoin Surges Past \$68,000 as ETF Inflows Hit New Record',
          summary:
              'Bitcoin continued its upward momentum crossing the \$68,000 mark as spot Bitcoin ETFs recorded their highest single-day inflows since launch.',
          source: 'CoinDesk',
          url: 'https://coindesk.com',
          imageUrl: 'https://picsum.photos/seed/news2/400/200',
          relatedSymbol: 'BTC-USD',
          category: 'crypto',
          publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
          sentiment: 1,
        ),
        NewsModel(
          id: '3',
          headline: 'Federal Reserve Signals Potential Rate Cut in March Meeting',
          summary:
              'Fed Chair Jerome Powell hinted at a possible rate cut in the upcoming March FOMC meeting, citing cooling inflation data and stable employment numbers.',
          source: 'Bloomberg',
          url: 'https://bloomberg.com',
          imageUrl: 'https://picsum.photos/seed/news3/400/200',
          category: 'economy',
          publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
          sentiment: 0,
        ),
        NewsModel(
          id: '4',
          headline: 'NVIDIA Stock Rallies on AI Chip Demand Outlook',
          summary:
              'NVIDIA shares jumped over 3% after the company provided a bullish outlook for its data center GPU business driven by surging AI infrastructure investments.',
          source: 'CNBC',
          url: 'https://cnbc.com',
          imageUrl: 'https://picsum.photos/seed/news4/400/200',
          relatedSymbol: 'NVDA',
          category: 'technology',
          publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
          sentiment: 1,
        ),
        NewsModel(
          id: '5',
          headline: 'Tesla Cuts EV Prices in Europe Amid Intensifying Competition',
          summary:
              'Tesla announced price reductions across its European lineup as it faces growing competition from local manufacturers and Chinese EV brands.',
          source: 'Financial Times',
          url: 'https://ft.com',
          imageUrl: 'https://picsum.photos/seed/news5/400/200',
          relatedSymbol: 'TSLA',
          category: 'automotive',
          publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
          sentiment: -1,
        ),
        NewsModel(
          id: '6',
          headline: 'EUR/USD Steadies as ECB Maintains Hawkish Stance',
          summary:
              'The Euro held firm against the US Dollar following ECB President Lagarde\'s comments reaffirming commitment to keeping rates elevated until inflation reaches target.',
          source: 'ForexLive',
          url: 'https://forexlive.com',
          relatedSymbol: 'EUR/USD',
          category: 'forex',
          publishedAt: DateTime.now().subtract(const Duration(hours: 14)),
          sentiment: 0,
        ),
        NewsModel(
          id: '7',
          headline: 'Meta AI Investments Drive Advertising Revenue to New Heights',
          summary:
              'Meta Platforms reported a 24% increase in advertising revenue, attributing the growth to AI-powered ad targeting tools and increased engagement across its platforms.',
          source: 'The Verge',
          url: 'https://theverge.com',
          imageUrl: 'https://picsum.photos/seed/news7/400/200',
          relatedSymbol: 'META',
          category: 'technology',
          publishedAt: DateTime.now().subtract(const Duration(hours: 18)),
          sentiment: 1,
        ),
        NewsModel(
          id: '8',
          headline: 'Global Markets Mixed as Oil Prices Rise on Middle East Tensions',
          summary:
              'Global equity markets showed mixed performance as crude oil prices climbed amid ongoing geopolitical tensions in the Middle East, impacting energy sector stocks.',
          source: 'AP',
          url: 'https://apnews.com',
          imageUrl: 'https://picsum.photos/seed/news8/400/200',
          category: 'markets',
          publishedAt: DateTime.now().subtract(const Duration(days: 1)),
          sentiment: -1,
        ),
      ];

  @override
  NewsModel copyWith({
    String? id,
    String? headline,
    String? summary,
    String? source,
    String? url,
    String? imageUrl,
    String? relatedSymbol,
    String? category,
    DateTime? publishedAt,
    int? sentiment,
  }) {
    return NewsModel(
      id: id ?? this.id,
      headline: headline ?? this.headline,
      summary: summary ?? this.summary,
      source: source ?? this.source,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      relatedSymbol: relatedSymbol ?? this.relatedSymbol,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      sentiment: sentiment ?? this.sentiment,
    );
  }
}
