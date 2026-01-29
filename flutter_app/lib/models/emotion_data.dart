class EmotionData {
  final String emotion;
  final String emoji;
  final String mood;
  final String color;
  
  EmotionData({
    required this.emotion,
    required this.emoji,
    required this.mood,
    required this.color,
  });
}

class EmotionDatabase {
  static final Map<String, EmotionData> emotions = {
    'happy': EmotionData(
      emotion: 'Happy',
      emoji: '😊',
      mood: 'You look joyful!',
      color: '#FFD700',
    ),
    'sad': EmotionData(
      emotion: 'Sad',
      emoji: '😢',
      mood: 'Feeling low...',
      color: '#4169E1',
    ),
    'angry': EmotionData(
      emotion: 'Angry',
      emoji: '😠',
      mood: 'Take a deep breath...',
      color: '#FF6347',
    ),
    'calm': EmotionData(
      emotion: 'Calm',
      emoji: '😐',
      mood: 'Peaceful and composed',
      color: '#90EE90',
    ),
    'surprised': EmotionData(
      emotion: 'Surprised',
      emoji: '😲',
      mood: 'Something exciting!',
      color: '#FF69B4',
    ),
    'neutral': EmotionData(
      emotion: 'Calm',
      emoji: '😐',
      mood: 'Peaceful and composed',
      color: '#90EE90',
    ),
  };

  static final Map<String, List<String>> suggestions = {
    'sad': [
      'Take a short walk outside 🚶',
      'Listen to your favorite music 🎵',
      'Talk to a friend or family member 💙',
      'Watch something funny 😄',
      'Do something you enjoy 🎨',
    ],
    'angry': [
      'Take 5 deep breaths 🧘',
      'Count to 10 slowly ⏳',
      'Drink some water 💧',
      'Take a break from what you\'re doing ⏸️',
      'Go for a quick walk 🚶',
    ],
  };

  static final List<String> jokes = [
    'Why don\'t scientists trust atoms? Because they make up everything! 😄',
    'What do you call a bear with no teeth? A gummy bear! 🐻',
    'Why did the scarecrow win an award? He was outstanding in his field! 🌾',
    'What do you call a fish wearing a crown? A king fish! 🐠👑',
    'Why don\'t eggs tell jokes? They\'d crack up! 🥚😂',
    'What\'s orange and sounds like a parrot? A carrot! 🥕',
    'How do you organize a space party? You planet! 🪐🎉',
    'Why did the bicycle fall over? It was two-tired! 🚲',
    'What do you call a sleeping bull? A bulldozer! 🐂😴',
    'Why don\'t skeletons fight each other? They don\'t have the guts! 💀',
  ];

  static String getRandomJoke() {
    jokes.shuffle();
    return jokes.first;
  }

  static String? getSuggestion(String emotion) {
    final suggestionList = suggestions[emotion.toLowerCase()];
    if (suggestionList != null && suggestionList.isNotEmpty) {
      suggestionList.shuffle();
      return suggestionList.first;
    }
    return null;
  }

  static EmotionData getEmotionData(String emotion) {
    return emotions[emotion.toLowerCase()] ?? emotions['calm']!;
  }
}
