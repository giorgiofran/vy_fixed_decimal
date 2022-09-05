/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'package:test/test.dart';

import 'package:vy_fixed_decimal/src/extension/num_extension.dart';

void main() {
  test('Min', () {
    expect(10.min(15), 10);
    expect(20.min(15), 15);
    expect(10.0.min(15), 10.0);
    expect(20.0.min(15), 15.0);
    expect(10.4.min(10.3), 10.3);
    expect(10.2.min(10.3), 10.2);
  });
  test('Max', () {
    expect(10.max(15), 15);
    expect(20.max(15), 20);
    expect(10.0.max(15), 15.0);
    expect(20.0.max(15), 20.0);
    expect(10.4.max(10.3), 10.4);
    expect(10.2.max(10.3), 10.3);
  });
}
