extension NumExtension on num {
  num min(num other) => this < other ? this : other;

  num max(num other) => this > other ? this : other;
}
