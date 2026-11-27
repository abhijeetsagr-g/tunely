/// One beat of the rolling credits.
///
/// Every entry occupies exactly one row of the roll (see
/// `RollingCreditsList.rowHeight`), which keeps the scroll maths cheap and
/// the roll visually even — just like movie credits.
sealed class CreditEntry {
  const CreditEntry();
}

/// The opening card: big app name plus an optional tagline.
class CreditTitle extends CreditEntry {
  const CreditTitle(this.title, {this.subtitle});

  final String title;
  final String? subtitle;
}

/// A group heading, e.g. "Developer", "Testers".
class CreditSection extends CreditEntry {
  const CreditSection(this.title);

  final String title;
}

/// A person with a role above their name.
class CreditPerson extends CreditEntry {
  const CreditPerson({required this.role, required this.name});

  final String role;
  final String name;
}

/// A bare name — handy for long tester lists.
class CreditName extends CreditEntry {
  const CreditName(this.name);

  final String name;
}

/// A small italic line, e.g. "Thanks for listening."
class CreditNote extends CreditEntry {
  const CreditNote(this.text);

  final String text;
}

/// Empty row, used to breathe between sections.
class CreditSpacer extends CreditEntry {
  const CreditSpacer();
}
