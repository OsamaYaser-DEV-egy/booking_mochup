import 'package:equatable/equatable.dart';

/// An amount of money in a single currency.
///
/// Modelled as a value object so arithmetic stays currency-safe: adding two
/// amounts in different currencies is a programming error, not a silent bug.
final class Money extends Equatable implements Comparable<Money> {
  const Money({required this.amount, required this.currency});

  const Money.egp(this.amount) : currency = 'EGP';

  final double amount;
  final String currency;

  Money operator *(num factor) =>
      Money(amount: amount * factor, currency: currency);

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(amount: amount + other.amount, currency: currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(amount: amount - other.amount, currency: currency);
  }

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return amount < other.amount;
  }

  bool operator >(Money other) {
    _assertSameCurrency(other);
    return amount > other.amount;
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return amount.compareTo(other.amount);
  }

  void _assertSameCurrency(Money other) {
    assert(
      currency == other.currency,
      'Cannot combine $currency with ${other.currency}.',
    );
  }

  @override
  List<Object?> get props => [amount, currency];
}
