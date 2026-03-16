// ─── Article Model ────────────────────────────────────────────────────────────

enum ArticleCategory {
  general,       // Free
  technology,    // Free
  science,       // Premium
  finance,       // Premium
  exclusive,     // Premium
}

class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final ArticleCategory category;
  final DateTime publishedAt;
  final String author;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.publishedAt,
    required this.author,
  });

  bool get isPremium =>
      category == ArticleCategory.science ||
          category == ArticleCategory.finance ||
          category == ArticleCategory.exclusive;

  String get categoryLabel {
    switch (category) {
      case ArticleCategory.general:
        return 'General';
      case ArticleCategory.technology:
        return 'Technology';
      case ArticleCategory.science:
        return 'Science';
      case ArticleCategory.finance:
        return 'Finance';
      case ArticleCategory.exclusive:
        return 'Exclusive';
    }
  }
}

// ─── Mock Article Service ─────────────────────────────────────────────────────

class ArticleService {
  static const int freeDailyLimit = 3;

  static List<Article> getAllArticles() {
    return [
      // Free articles
      Article(
        id: '1',
        title: 'The Future of Remote Work in 2025',
        summary: 'How distributed teams are reshaping modern workplaces.',
        content: _loremContent,
        imageUrl: 'https://picsum.photos/seed/remote/800/400',
        category: ArticleCategory.general,
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        author: 'Jane Mitchell',
      ),
      Article(
        id: '2',
        title: 'Flutter 4.0: What\'s New for Developers',
        summary: 'A deep dive into the latest Flutter release features.',
        content: _loremContent,
        imageUrl: 'https://picsum.photos/seed/flutter/800/400',
        category: ArticleCategory.technology,
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        author: 'Dev Patel',
      ),
      Article(
        id: '3',
        title: 'Understanding Open Source Licensing',
        summary: 'MIT, Apache, GPL — what they mean for your project.',
        content: _loremContent,
        imageUrl: 'https://picsum.photos/seed/oss/800/400',
        category: ArticleCategory.technology,
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        author: 'Sara Kim',
      ),
      Article(
        id: '4',
        title: 'Climate Tech: Innovations Saving the Planet',
        summary: 'Startups tackling climate change with cutting-edge science.',
        content: _loremContent,
        imageUrl: 'https://picsum.photos/seed/climate/800/400',
        category: ArticleCategory.general,
        publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
        author: 'Tom Clarke',
      ),

      // Premium articles
      Article(
        id: '5',
        title: 'CRISPR Breakthroughs: Gene Editing in 2025',
        summary: 'The latest advances in gene therapy and what they mean.',
        content: _loremContent,
        imageUrl: 'https://picsum.photos/seed/crispr/800/400',
        category: ArticleCategory.science,
        publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
        author: 'Dr. Amelia Ross',
      ),
      Article(
        id: '6',
        title: 'How to Build a \$1M Portfolio from Scratch',
        summary: 'Proven strategies from top-performing investors.',
        content: _loremContent,
        imageUrl: 'https://picsum.photos/seed/invest/800/400',
        category: ArticleCategory.finance,
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
        author: 'Michael Tan',
      ),
      Article(
        id: '7',
        title: 'Exclusive: Inside the AI Chip War',
        summary: 'An in-depth look at NVIDIA, AMD, and emerging challengers.',
        content: _loremContent,
        imageUrl: 'https://picsum.photos/seed/chips/800/400',
        category: ArticleCategory.exclusive,
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        author: 'ReadWise Staff',
      ),
      Article(
        id: '8',
        title: 'Quantum Computing: Closer Than You Think',
        summary: 'Why 2025 might be the year quantum goes mainstream.',
        content: _loremContent,
        imageUrl: 'https://picsum.photos/seed/quantum/800/400',
        category: ArticleCategory.science,
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        author: 'Dr. Felix Wang',
      ),
      Article(
        id: '9',
        title: 'The Hidden Tax Benefits Most People Miss',
        summary: 'Expert advice on maximizing your returns this year.',
        content: _loremContent,
        imageUrl: 'https://picsum.photos/seed/tax/800/400',
        category: ArticleCategory.finance,
        publishedAt: DateTime.now().subtract(const Duration(hours: 9)),
        author: 'Priya Sharma',
      ),
    ];
  }

  static List<Article> getFreeArticles() {
    return getAllArticles().where((a) => !a.isPremium).toList();
  }

  static List<Article> getPremiumArticles() {
    return getAllArticles().where((a) => a.isPremium).toList();
  }

  static const String _loremContent = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet.

At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.
  ''';
}