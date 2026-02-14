/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.
library;

import 'package:rational/rational.dart';
import 'package:test/test.dart';

extension RationalExt on Rational {
  bool get isNegative => signum < 0;
}

Rational mod(Rational one, Rational other) {
  final remainder = one.remainder(other);
  if (remainder == Rational(BigInt.from(0))) {
    return remainder;
  }
  if (remainder.isNegative) {
    return other.abs() + remainder;
  }
  return remainder;
}

Rational mod2(Rational one, Rational other) {
  final remainder = one.remainder(other);
  if (remainder.isNegative) {
    return other.abs() + remainder;
  }
  return remainder;
}

void main() {
  test('test Modulus', () {
    expect(Rational(BigInt.from(5)) % Rational(BigInt.from(4)),
        equals(Rational(BigInt.from(1))));
    expect(Rational(BigInt.from(-5)) % Rational(BigInt.from(4)),
        equals(Rational(BigInt.from(3))));
    expect(Rational(BigInt.from(5)) % Rational(BigInt.from(-4)),
        equals(Rational(BigInt.from(1))));
    expect(Rational(BigInt.from(-5)) % Rational(BigInt.from(-4)),
        equals(Rational(BigInt.from(3))));
    expect(Rational(BigInt.from(4)) % Rational(BigInt.from(4)),
        equals(Rational(BigInt.from(0))));
    expect(Rational(BigInt.from(-4)) % Rational(BigInt.from(4)),
        equals(Rational(BigInt.from(0))));
    expect(Rational(BigInt.from(4)) % Rational(BigInt.from(-4)),
        equals(Rational(BigInt.from(0))));
    expect(Rational(BigInt.from(-4)) % Rational(BigInt.from(-4)),
        equals(Rational(BigInt.from(0))));
  });

  test('test Version', () {
    expect(mod(Rational(BigInt.from(5)), Rational(BigInt.from(4))),
        equals(Rational(BigInt.from(1))));
    expect(mod(Rational(BigInt.from(-5)), Rational(BigInt.from(4))),
        equals(Rational(BigInt.from(3))));
    expect(mod(Rational(BigInt.from(5)), Rational(BigInt.from(-4))),
        equals(Rational(BigInt.from(1))));
    expect(mod(Rational(BigInt.from(-5)), Rational(BigInt.from(-4))),
        equals(Rational(BigInt.from(3))));
    expect(mod(Rational(BigInt.from(4)), Rational(BigInt.from(4))),
        equals(Rational(BigInt.from(0))));
    expect(mod(Rational(BigInt.from(-4)), Rational(BigInt.from(4))),
        equals(Rational(BigInt.from(0))));
    expect(mod(Rational(BigInt.from(4)), Rational(BigInt.from(-4))),
        equals(Rational(BigInt.from(0))));
    expect(mod(Rational(BigInt.from(-4)), Rational(BigInt.from(-4))),
        equals(Rational(BigInt.from(0))));
    expect(mod(Rational(BigInt.from(2)), Rational(BigInt.from(1))),
        equals(Rational(BigInt.from(0))));
    expect(mod(Rational(BigInt.from(0)), Rational(BigInt.from(1))),
        equals(Rational(BigInt.from(0))));
    expect(
        mod(Rational(BigInt.from(89), BigInt.from(10)),
            Rational(BigInt.from(11), BigInt.from(10))),
        equals(Rational(BigInt.from(1), BigInt.from(10))));
    expect(
        mod(Rational(BigInt.from(-12), BigInt.from(10)),
            Rational(BigInt.from(5), BigInt.from(10))),
        equals(Rational(BigInt.from(3), BigInt.from(10))));
    expect(
        mod(Rational(BigInt.from(-12), BigInt.from(10)),
            Rational(BigInt.from(-5), BigInt.from(10))),
        equals(Rational(BigInt.from(3), BigInt.from(10))));
    expect(mod(Rational(BigInt.from(-2200)), Rational(BigInt.from(1000))),
        equals(Rational(BigInt.from(800))));
  });

  test('test new Version "compact"', () {
    expect(mod2(Rational(BigInt.from(5)), Rational(BigInt.from(4))),
        equals(Rational(BigInt.from(1))));
    expect(mod2(Rational(BigInt.from(-5)), Rational(BigInt.from(4))),
        equals(Rational(BigInt.from(3))));
    expect(mod2(Rational(BigInt.from(5)), Rational(BigInt.from(-4))),
        equals(Rational(BigInt.from(1))));
    expect(mod2(Rational(BigInt.from(-5)), Rational(BigInt.from(-4))),
        equals(Rational(BigInt.from(3))));
    expect(mod2(Rational(BigInt.from(4)), Rational(BigInt.from(4))),
        equals(Rational(BigInt.from(0))));
    expect(mod2(Rational(BigInt.from(-4)), Rational(BigInt.from(4))),
        equals(Rational(BigInt.from(0))));
    expect(mod2(Rational(BigInt.from(4)), Rational(BigInt.from(-4))),
        equals(Rational(BigInt.from(0))));
    expect(mod2(Rational(BigInt.from(-4)), Rational(BigInt.from(-4))),
        equals(Rational(BigInt.from(0))));
  });
}
