import '../../../l10n/app_localizations.dart';

/// Seçilebilir ilgi alanı — id (Firestore'da saklanır) + emoji.
class Interest {
  final String id;
  final String emoji;
  const Interest(this.id, this.emoji);
}

const kInterests = <Interest>[
  Interest('coffee', '☕'),
  Interest('music', '🎶'),
  Interest('sports', '⚽'),
  Interest('art', '🎨'),
  Interest('travel', '✈️'),
  Interest('food', '🍜'),
  Interest('gaming', '🎮'),
  Interest('movies', '🎬'),
  Interest('books', '📚'),
  Interest('fitness', '💪'),
  Interest('nightlife', '🌃'),
  Interest('nature', '🌿'),
  Interest('tech', '💻'),
  Interest('photography', '📷'),
];

String interestLabel(AppL10n t, String id) {
  switch (id) {
    case 'coffee':
      return t.intCoffee;
    case 'music':
      return t.intMusic;
    case 'sports':
      return t.intSports;
    case 'art':
      return t.intArt;
    case 'travel':
      return t.intTravel;
    case 'food':
      return t.intFood;
    case 'gaming':
      return t.intGaming;
    case 'movies':
      return t.intMovies;
    case 'books':
      return t.intBooks;
    case 'fitness':
      return t.intFitness;
    case 'nightlife':
      return t.intNightlife;
    case 'nature':
      return t.intNature;
    case 'tech':
      return t.intTech;
    case 'photography':
      return t.intPhotography;
    default:
      return id;
  }
}
