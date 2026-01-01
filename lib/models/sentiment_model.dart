class Sentiment {
  final String emotion;
  late final String iconPath; // path to asset icon

  Sentiment({required this.emotion}) {
    switch (emotion.toLowerCase()) {
      case 'joy':
        iconPath = 'assets/icons/joy.png';
        break;
      case 'calm':
        iconPath = 'assets/icons/calm.png';
        break;
      case 'excite':
        iconPath = 'assets/icons/excited.png';
        break;
      case 'minimalist':
        iconPath = 'assets/icons/minimalist.png';
        break;
      case 'cozy':
        iconPath = 'assets/icons/house.png';
        break;
      default:
        iconPath = 'assets/icons/joy.png';
    }
  }
}