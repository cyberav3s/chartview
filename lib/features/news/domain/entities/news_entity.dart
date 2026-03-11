import 'package:equatable/equatable.dart';

class News extends Equatable {
  final String id;
  final String headline;
  final String summary;
  final String source;
  final String url;
  final String? imageUrl;
  final String? relatedSymbol;
  final String category;
  final DateTime publishedAt;
  final int? sentiment; // -1 negative, 0 neutral, 1 positive

  const News({
    required this.id,
    required this.headline,
    required this.summary,
    required this.source,
    required this.url,
    this.imageUrl,
    this.relatedSymbol,
    required this.category,
    required this.publishedAt,
    this.sentiment,
  });

  News copyWith({
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
    return News(
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

  @override
  List<Object?> get props =>
      [id, headline, summary, source, url, imageUrl, relatedSymbol, category, publishedAt, sentiment];
}
