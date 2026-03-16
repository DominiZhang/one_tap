class Money {
  final int cents;

  const Money._(this.cents);

  factory Money.cents(int cents) => Money._(cents);
}

